import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/services/local_storage_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import '../mixins/player_audio_mixin.dart';
import '../mixins/player_subtitle_mixin.dart';
import '../mixins/player_settings_mixin.dart';
import '../mixins/player_ui_mixin.dart';

class MediaPlayerController extends GetxController
    with PlayerAudioMixin, PlayerSubtitleMixin, PlayerSettingsMixin, PlayerUIMixin {

  //: Intancias
  // Instancias y propiedades de media_kit
  @override
  late final Player player;
  late final VideoController videoController;
  final PlayerStorageService _storage = Get.find<PlayerStorageService>();
  
  @override
  PlayerStorageService get storage => _storage;
  late final String videoPath;

  //: Estados reactivos 
  // Estados de reproducción y tiempo
  @override
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  bool _hasRestoredPosition = false;
  bool _isDisposed = false;

  // Lista para cancelar los listeners antes de destruir el player
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    videoPath = Get.arguments as String;

    _loadStoredPreferences();

    player = Player();
    videoController = VideoController(player);

    _listenToStreams();

    player.open(Media(videoPath)).then((_) {
      applySeekingMode(isFastSeekingEnabled.value);
      player.setRate(playbackSpeed.value);
      player.setVolume(volume.value);
      applyHdEnhancer(isHdEnhancerEnabled.value); 
    });

    startHideControlsTimer();
  }

  @override
  void onClose() {
    _isDisposed = true;
    cancelUITimers();

    // 1. Cancelar todas las suscripciones a los streams
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 2. Guardar la posición antes de destruir
    if (position.value.inMilliseconds > 0) {
      _storage.savePosition(videoPath, position.value.inMilliseconds);
    }

    // 3. Detener y destruir el reproductor de forma segura
    final playerToDispose = player;
    Future.microtask(() async {
      await playerToDispose.stop();
      await playerToDispose.dispose();
    });

    super.onClose();
  }

  /// Carga la configuración previa guardada en el almacenamiento local.
  void _loadStoredPreferences() {
    playbackSpeed.value = _storage.speed;
    volume.value = _storage.volume;
    subtitlesEnabled.value = _storage.subtitlesEnabled;
    isFastSeekingEnabled.value = _storage.isFastSeeking;
    brightness.value = _storage.brightness;
    savedAudioTrackId = _storage.audioTrackId;
  }

  //: Key Listeners (Streams del reproductor)
  /// Escucha los streams del reproductor para actualizar los estados reactivos.
  void _listenToStreams() {
    _subscriptions.addAll([
      // Escuchar estado de reproducción y tiempo
      player.stream.playing.listen((val) => isPlaying.value = val),
      
      // Escuchar duración y restaurar posición cuando el video esté listo
      player.stream.duration.listen((dur) {
        duration.value = dur;
        if (!_hasRestoredPosition && dur.inMilliseconds > 0) {
          _hasRestoredPosition = true;
          final savedPositionMs = _storage.getPosition(videoPath);
          if (savedPositionMs > 0 && savedPositionMs < dur.inMilliseconds - 2000) {
            player.seek(Duration(milliseconds: savedPositionMs));
            showOSD('Reanudando posición');
          }
        }
      }),

      player.stream.position.listen((val) {
        position.value = val;
      }),

      player.stream.volume.listen((val) => volume.value = val),
      player.stream.rate.listen((val) => playbackSpeed.value = val),

      // Escuchar pistas disponibles y aplicarlas según preferencias
      player.stream.tracks.listen((tracks) {
        if (_isDisposed) return;
        
        availableSubtitles.assignAll(tracks.subtitle);
        availableAudioTracks.assignAll(tracks.audio);

        // 1. Manejo y Restauración de Subtítulos
        if (!subtitlesEnabled.value) {
          player.setSubtitleTrack(SubtitleTrack.no());
        } else if (tracks.subtitle.isNotEmpty) {
          final validSubtitles = tracks.subtitle.where((t) => t != SubtitleTrack.no()).toList();
          if (validSubtitles.isNotEmpty) {
            final trackToSelect = validSubtitles.firstWhere(
              (t) => t.id == lastSelectedSubtitle.id || t.language == lastSelectedSubtitle.language,
              orElse: () => validSubtitles.first,
            );
            setSubtitleTrack(trackToSelect);
          }
        }

        // 2. Manejo y Restauración de Pista de Audio
        if (savedAudioTrackId != null && tracks.audio.isNotEmpty) {
          final matchedAudio = tracks.audio.firstWhere(
            (t) => t.id == savedAudioTrackId || t.language == savedAudioTrackId,
            orElse: () => currentAudioTrack.value,
          );
          if (matchedAudio != currentAudioTrack.value) {
            setAudioTrack(matchedAudio);
          }
        }
      }),

      player.stream.track.listen((track) {
        if (_isDisposed) return;
        currentSubtitle.value = track.subtitle;
        currentAudioTrack.value = track.audio;
      }),
    ]);

    // Guarda la posición automáticamente con debounce de 1 segundo
    debounce(position, (pos) {
      if (!_isDisposed && pos.inMilliseconds > 0) {
        _storage.savePosition(videoPath, pos.inMilliseconds);
      }
    }, time: const Duration(seconds: 1));
  }

  //+ Reproducción
  /// Alterna entre reproducir y pausar el video.
  void togglePlayPause() {
    player.playOrPause();
    startHideControlsTimer();
  }

  /// Salta a una posición específica en el video.
  void seekTo(Duration pos) => player.seek(pos);

  /// Salta hacia adelante o hacia atrás en el video en función de los segundos proporcionados.
  void seekRelative(int seconds) {
    final newPos = position.value + Duration(seconds: seconds);
    final clampedPos = Duration(
      milliseconds: newPos.inMilliseconds.clamp(0, duration.value.inMilliseconds),
    );
    player.seek(clampedPos);
    showOSD(seconds > 0 ? '+${seconds}s' : '${seconds}s');
  }
  //!+

  //+ Navegación
  /// Salir del reproductor, deteniendo la reproducción y cerrando la pantalla.
  Future<void> exitPlayer() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (isFullScreen.value) {
      isFullScreen.value = false;
      await windowManager.setFullScreen(false);
    }

    await player.pause();
    Get.back();
  }
  //!+

  /// Método auxiliar para centralizar el guardado en disco
  @override
  void saveAllSettings() {
    _storage.saveSettings(
      speed: playbackSpeed.value,
      volume: volume.value,
      subtitles: subtitlesEnabled.value,
      fastSeeking: isFastSeekingEnabled.value,
      brightness: brightness.value,
      audioTrackId: savedAudioTrackId,
    );
  }

  //+ Getters para widgets de UI
  double get getMediaMaxDuration {
    return duration.value.inMilliseconds.toDouble() > 0
        ? duration.value.inMilliseconds.toDouble()
        : 1.0;
  }

  double get getPositionInMilliseconds {
    return position.value.inMilliseconds
        .toDouble()
        .clamp(0.0, duration.value.inMilliseconds.toDouble());
  }
  //!+
}