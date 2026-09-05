import 'dart:collection';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';



/// Servicio de almacenamiento local para la configuración del reproductor.
class PlayerStorageService extends GetxService {
  late final GetStorage _box;

  // Claves para evitar errores de tipeo (Magic Strings)
  static const _kSpeed       = 'player_speed';
  static const _kVolume      = 'player_volume';
  static const _kSubtitles   = 'player_subtitles_enabled';
  static const _kAudioTrack  = 'player_audio_track_id';
  static const _kFastSeeking = 'player_fast_seeking';
  static const _kBrightness  = 'player_brightness';
  static const _kPositions   = 'player_video_positions';
  static const _kAutoResume = 'player_auto_resume';

  /// Inicializa la caja de almacenamiento
  Future<PlayerStorageService> init() async {
    _box = GetStorage();
    return this;
  }



  /// Guardar configuraciones de forma individual o agrupada
  void saveSettings({
    required double speed,
    required double volume,
    required bool subtitles,
    required bool fastSeeking,
    required double brightness,
    String? audioTrackId,
  }) {
    _box.write(_kSpeed, speed);
    _box.write(_kVolume, volume);
    _box.write(_kSubtitles, subtitles);
    _box.write(_kFastSeeking, fastSeeking);
    _box.write(_kBrightness, brightness);
    if (audioTrackId != null) {
      _box.write(_kAudioTrack, audioTrackId);
    }
  }



  /// Guarda la última posición alcanzada en un video manteniendo un máximo de 3 elementos en historial.
  void savePosition(String videoPath, int positionInMs) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kPositions) ?? {};
    
    // Usamos LinkedHashMap para preservar el orden de inserción/actualización
    final LinkedHashMap<String, int> positions = LinkedHashMap<String, int>.from(
      rawPositions.map((k, v) => MapEntry(k, v as int)),
    );

    // Si ya existe la ruta, la removemos primero para reinsertarla al final (como más reciente)
    if (positions.containsKey(videoPath)) {
      positions.remove(videoPath);
    }

    // Insertar la posición del video actual al final
    positions[videoPath] = positionInMs;

    // Si supera el límite de 5, eliminamos el más antiguo (el primer elemento)
    while (positions.length > 5) {
      positions.remove(positions.keys.first);
    }

    _box.write(_kPositions, positions);
  }



  /// Obtiene la posición guardada de un video (0 por defecto).
  int getPosition(String videoPath) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kPositions) ?? {};
    return rawPositions[videoPath] as int? ?? 0;
  }



  /// Habilita o deshabilita la reanudación automática del reproductor de medios.
  void setAutoResume(bool enabled) => _box.write(_kAutoResume, enabled);



  /// Lecturas individuales con valores por defecto centralizados
  double get speed           => _box.read<double>(_kSpeed)      ?? 1.0;
  double get volume          => _box.read<double>(_kVolume)     ?? 100.0;
  bool get subtitlesEnabled  => _box.read<bool>(_kSubtitles)    ?? false;
  String? get audioTrackId   => _box.read<String>(_kAudioTrack);
  bool get isFastSeeking     => _box.read<bool>(_kFastSeeking)  ?? true;
  double get brightness      => _box.read<double>(_kBrightness) ?? 1.0;
  bool get autoResumeEnabled => _box.read<bool>(_kAutoResume)   ?? true;
}