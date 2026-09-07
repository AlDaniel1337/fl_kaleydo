import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/data/services/local_storage_service/player_storage_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import 'mixins/player_audio_mixin.dart';
import 'mixins/player_playlist_mixin.dart';
import 'mixins/player_settings_mixin.dart';
import 'mixins/player_subtitle_mixin.dart';
import 'mixins/player_ui_mixin.dart';

/// Controlador principal del reproductor de medios que combina múltiples mixins
/// para manejar audio, subtítulos, configuración, interfaz de usuario y lista de reproducción.
class MediaPlayerController extends GetxController with PlayerAudioMixin, PlayerSubtitleMixin, PlayerSettingsMixin, PlayerUIMixin, PlayerPlaylistMixin {

  //+ VARIABLES
  // Instancias de MediaKit y Servicios
  @override
  late final Player player;
  late final VideoController videoController;
  final PlayerStorageService _storage = Get.find<PlayerStorageService>();

  @override
  PlayerStorageService get storage => _storage;

  late String videoPath;
  bool _isArgsInitialized = false;

  // Estados de reproducción y tiempo
  @override
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  @override
  final Rx<Duration> duration = Duration.zero.obs;

  bool _hasRestoredPosition = false;
  bool _isDisposed = false;

  // Cancelación de suscripciones
  final List<StreamSubscription> _subscriptions = [];
  //!+



  //+ CICLO DE VIDA
  @override
  void onInit() {
    super.onInit();

    _initializeArguments();
    if (!_isArgsInitialized) return;

    _loadStoredPreferences();

    player = Player();
    videoController = VideoController(player);

    _listenToStreams();
    _startPlayer();

    startHideControlsTimer();
  }

  @override
  void onClose() {
    _isDisposed = true;
    cancelUITimers();
    cancelPlaylistTimers();

    // 1. Cancelar suscripciones
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    // 2. Guardar progreso actual antes de cerrar
    if (position.value.inMilliseconds > 0) {
      _saveCurrentProgress(position.value.inMilliseconds);
    }

    // 3. Liberar reproductor
    final playerToDispose = player;
    Future.microtask(() async {
      await playerToDispose.stop();
      await playerToDispose.dispose();
    });

    super.onClose();
  }
  //!+



  //+ NAVEGACIÓN Y REPRODUCCIÓN
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
      milliseconds:
        newPos.inMilliseconds.clamp(
          0, 
          duration.value.inMilliseconds
        ),
    );
    player.seek(clampedPos);
    showOSD(seconds > 0 ? '+$seconds s' : '$seconds s');
  }


  /// Saltos porcentuales (Tecla 0-9 -> 0% a 90%).
  void seekToPercentage(int percentage) {
    if (duration.value == Duration.zero) return;
    final targetMs =
        (duration.value.inMilliseconds * (percentage / 100)).toInt();
    seekTo(Duration(milliseconds: targetMs));
    showOSD('Salto: $percentage%');
  }


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


  /// Cambiar al siguiente episodio.
  void goToNextEpisode() {
    playNextEpisode();
    videoPath = playlist[currentIndex].path;
    _hasRestoredPosition = false;
  }


  /// Cambiar al episodio anterior.
  void goToPreviousEpisode() {
    playPreviousEpisode();
    videoPath = playlist[currentIndex].path;
    _hasRestoredPosition = false;
  }
  //!+

  //+ CARGA Y GESTIÓN DE DATOS
  /// Abre el archivo de video inicial aplicando las configuraciones locales.
  Future<void> _startPlayer() async {
    final savedMs = _storage.getPosition(videoPath);

    await player.open(
      Media(
        videoPath,
        start: savedMs > 0 ? Duration(milliseconds: savedMs) : Duration.zero,
      ),
    );

    applySeekingMode(isFastSeekingEnabled.value);
    player.setRate(playbackSpeed.value);
    player.setVolume(volume.value);
    applyHdEnhancer(isHdEnhancerEnabled.value);
  }


  /// Método auxiliar para centralizar el guardado en disco.
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


  /// Carga la configuración previa guardada en el almacenamiento local.
  void _loadStoredPreferences() {
    playbackSpeed.value = _storage.speed;
    volume.value = _storage.volume;
    subtitlesEnabled.value = _storage.subtitlesEnabled;
    isFastSeekingEnabled.value = _storage.isFastSeeking;
    brightness.value = _storage.brightness;
    savedAudioTrackId = _storage.audioTrackId;
  }


  /// Guarda el progreso actual en el servicio de almacenamiento.
  void _saveCurrentProgress(int positionMs) {
    if (videoPath.isEmpty) return;

    final pathSegments = videoPath.split(RegExp(r'[/\\]'));
    String detectedMediaType = 'anime';

    for (final segment in pathSegments) {
      if (segment.startsWith('_')) {
        detectedMediaType = segment;
        break;
      }
    }

    String franchiseName = 'Desconocida';
    String franchisePath = '';
    if (pathSegments.length >= 3) {
      franchiseName = pathSegments[pathSegments.length - 2];
      franchisePath = videoPath.substring(
        0,
        videoPath.lastIndexOf(Platform.pathSeparator),
      );
    } else {
      franchisePath = videoPath;
    }

    String videoTitle = franchiseName;
    if (playlist.isNotEmpty &&
        currentIndex >= 0 &&
        currentIndex < playlist.length) {
      videoTitle = playlist[currentIndex].title;
    } else {
      videoTitle = pathSegments.last;
    }

    _storage.savePosition(
      mediaType: detectedMediaType,
      franchiseName: franchiseName,
      franchisePath: franchisePath,
      videoPath: videoPath,
      videoTitle: videoTitle,
      positionInMs: positionMs,
    );
  }
  //!+

  //+ MÉTODOS AUXILIARES Y LISTENERS
  /// Valida e inicializa los argumentos pasados por GetX.
  void _initializeArguments() {
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      playlist = (args['playlist'] as List?)?.cast<FranchiseItemModel>() ?? [];
      currentIndex = args['currentIndex'] as int? ?? 0;

      if (playlist.isNotEmpty && currentIndex < playlist.length) {
        videoPath = playlist[currentIndex].path;
        _isArgsInitialized = true;
      }
    } else if (args is String && args.isNotEmpty) {
      videoPath = args;
      _isArgsInitialized = true;
    }

    if (!_isArgsInitialized) {
      Get.snackbar('Error', 'No se pudo cargar la ruta del video.');
    }
  }


  /// Escucha los streams del reproductor para actualizar los estados reactivos.
  void _listenToStreams() {
    _subscriptions.addAll([
      player.stream.playing.listen((val) => isPlaying.value = val),

      player.stream.duration.listen((dur) {
        duration.value = dur;
        if (!_hasRestoredPosition && dur.inMilliseconds > 0) {
          _hasRestoredPosition = true;
          final savedPositionMs = _storage.getPosition(videoPath);
          if (savedPositionMs > 0 &&
              savedPositionMs < dur.inMilliseconds - 2000) {
            player.seek(Duration(milliseconds: savedPositionMs));
            showOSD('Reanudando posición');
          }
        }
      }),

      player.stream.position.listen((pos) {
        position.value = pos;
        checkAutoPlayTrigger(pos);
      }),

      player.stream.volume.listen((val) => volume.value = val),
      player.stream.rate.listen((val) => playbackSpeed.value = val),

      player.stream.tracks.listen((tracks) {
        if (_isDisposed) return;

        availableSubtitles.assignAll(tracks.subtitle);
        availableAudioTracks.assignAll(tracks.audio);

        _restoreSubtitles(tracks.subtitle);
        _restoreAudioTrack(tracks.audio);
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
        final isNearEnd = (duration.value - pos).inSeconds < 30;
        _saveCurrentProgress(isNearEnd ? 0 : pos.inMilliseconds);
      }
    }, time: const Duration(seconds: 1));
  }


  /// Restaura la pista de subtítulos previamente seleccionada si está habilitada.
  void _restoreSubtitles(List<SubtitleTrack> subtitles) {
    if (!subtitlesEnabled.value) {
      player.setSubtitleTrack(SubtitleTrack.no());
    } else if (subtitles.isNotEmpty) {
      final validSubtitles =
          subtitles.where((t) => t != SubtitleTrack.no()).toList();
      if (validSubtitles.isNotEmpty) {
        final trackToSelect = validSubtitles.firstWhere(
          (t) =>
              t.id == lastSelectedSubtitle.id ||
              t.language == lastSelectedSubtitle.language,
          orElse: () => validSubtitles.first,
        );
        setSubtitleTrack(trackToSelect);
      }
    }
  }

  /// Restaura la pista de audio previamente seleccionada si está disponible.
  void _restoreAudioTrack(List<AudioTrack> audioTracks) {
    if (savedAudioTrackId != null && audioTracks.isNotEmpty) {
      final matchedAudio = audioTracks.firstWhere(
        (t) => t.id == savedAudioTrackId || t.language == savedAudioTrackId,
        orElse: () => currentAudioTrack.value,
      );
      if (matchedAudio != currentAudioTrack.value) {
        setAudioTrack(matchedAudio);
      }
    }
  }

  // Getters para widgets de UI
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