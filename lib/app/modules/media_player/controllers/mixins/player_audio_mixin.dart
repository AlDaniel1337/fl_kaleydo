import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:media_kit/media_kit.dart';
import 'package:kaleydo/app/data/services/local_storage_service/player_storage_service.dart';


/// Mixin que proporciona funcionalidades relacionadas con el audio del reproductor.
mixin PlayerAudioMixin on GetxController {
  
  //: Referencias
  // Referencias necesarias del controlador principal
  Player get player;
  PlayerStorageService get storage;
  void showOSD(String text);
  void saveAllSettings();

  //: Variables
  // Estados de audio (volumen, boost, límite máximo)
  final RxDouble volume = 100.0.obs;
  double previousVolume = 0.0;
  final RxBool isVolumeBoostEnabled = false.obs;
  final RxDouble maxVolumeLimit = 100.0.obs;
  double _previousVolumeBeforeMute = 100.0;

  // Estados de pistas de audio
  final RxList<AudioTrack> availableAudioTracks = <AudioTrack>[].obs;
  final Rx<AudioTrack> currentAudioTrack = AudioTrack.auto().obs;
  String? savedAudioTrackId;



  //+ Volumen del reproductor
  /// Establece el volumen del reproductor.
  void setVolume(double val, {bool shouldMute = false}) {
    
    if (shouldMute) {
      previousVolume = volume.value;
      player.setVolume(0.0);
      return;
    }

    final clamped = val.clamp(0.0, maxVolumeLimit.value);

    volume.value = clamped;
    player.setVolume(clamped);
    saveAllSettings();
    showOSD('Volumen: ${clamped.toInt()}%');
  }

  /// Ajusta el volumen en función del desplazamiento del scroll.
  void handleScrollVolume(double delta) {
    final step = 5.0;
    final newVol = delta < 0 
      ? (volume.value + step) 
      : (volume.value - step);
    setVolume(newVol);
  }

  /// Alterna el estado de silencio del reproductor.
  // Activar / Silenciar Volumen (Tecla M)
  void toggleMute() {
    if (volume.value > 0) {
      _previousVolumeBeforeMute = volume.value;
      setVolume(0);
      showOSD('Silenciado (Mute)');
    } else {
      setVolume(_previousVolumeBeforeMute > 0 ? _previousVolumeBeforeMute : 100.0);
    }
  }
  //!+



  //+ Audio del reproductor
  /// Establece la pista de audio activa.
  void setAudioTrack(AudioTrack track) {
    player.setAudioTrack(track);
    savedAudioTrackId = track.id.isNotEmpty ? track.id : track.language;
    saveAllSettings();
    final String label = track.title ?? track.language ?? 'Audio';
    showOSD('Audio: $label');
  }
  //!+



  //+ Boost de Volumen
  /// Alternar el modo Boost
  void toggleVolumeBoost() {
    isVolumeBoostEnabled.value = !isVolumeBoostEnabled.value;
    
    // Si se desactiva el boost y el volumen superaba el 100%, lo bajamos a 100%
    if (!isVolumeBoostEnabled.value && volume.value > 100.0) {
      maxVolumeLimit.value = 100.0;
      setVolume(maxVolumeLimit.value);
    } else {
      maxVolumeLimit.value = 300.0;
      showOSD(isVolumeBoostEnabled.value 
        ? 'Amplificación Activada' 
        : 'Modo de Volumen Estándar (100%)');
    }
  }
  //!+



  //+ Métodos auxiliares
  /// Método auxiliar para obtener el color dinámico del tramo activo
  Color get currentVolumeColor {
    if (volume.value <= 100.0) {
      return Colors.white; // Base 0% - 100%
    } else if (volume.value <= 200.0) {
      return AppColors.primaryAccent; // Boost Nivel 1: 101% - 200% (Rosa)
    } else if (volume.value <= 300.0) {
      return const Color(0xFFFF9800); // Boost Nivel 2: 201% - 300% (Naranja)
    } else {
      return const Color(0xFFF44336); // Boost Nivel 3+: 301%+ (Rojo)
    }
  }
  //!+
}