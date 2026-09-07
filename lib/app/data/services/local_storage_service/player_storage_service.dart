// lib/app/data/services/player_storage_service.dart

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
  static const _kRecentMedia = 'player_recent_video_history'; // Nuevo historial estructurado
  static const _kAutoResume  = 'player_auto_resume';

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

  /// Guarda la última posición y actualiza el historial reciente por medio, franquicia y episodio.
  void savePosition({
    required String mediaType,     // Ej: '_anime'
    required String franchiseName, // Ej: 'anime1'
    required String franchisePath, // Ruta de la carpeta de la franquicia
    required String videoPath,     // Ruta exacta del archivo de video
    required String videoTitle,    // Título del capítulo/episodio
    required int positionInMs,     // Posición actual en milisegundos
  }) {
    // 1. Guardar la posición de reproducción por archivo individual (compatibilidad)
    final rawPositions = _box.read<Map<String, dynamic>>(_kPositions) ?? {};
    final LinkedHashMap<String, int> positions = LinkedHashMap<String, int>.from(
      rawPositions.map((k, v) => MapEntry(k, v as int)),
    );

    if (positions.containsKey(videoPath)) positions.remove(videoPath);
    positions[videoPath] = positionInMs;
    while (positions.length > 200) {
      positions.remove(positions.keys.first);
    }
    _box.write(_kPositions, positions);

    // 2. Gestionar historial estructurado por franquicia y tipo de medio (máximo 5 recientes por categoría)
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    List<Map<String, dynamic>> history = rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // Remover si ya existe la misma franquicia en este medio para reinsertarla arriba
    history.removeWhere((item) => 
      item['mediaType'] == mediaType && item['franchisePath'] == franchisePath
    );

    // Insertar al inicio de la lista
    history.insert(0, {
      'mediaType': mediaType,
      'franchiseName': franchiseName,
      'franchisePath': franchisePath,
      'lastVideoPath': videoPath,
      'lastVideoTitle': videoTitle,
      'positionInMs': positionInMs,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _box.write(_kRecentMedia, history);
  }

  /// Obtiene los medios recientes de video filtrados por tipo de medio (ej: '_anime')
  List<Map<String, dynamic>> getRecentMediaByType(String mediaType) {
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    return rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((item) => item['mediaType'] == mediaType)
        .take(5) // Límite estricto de 5 por medio
        .toList();
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
  
  /// Obtiene el último video/episodio reproducido de una franquicia específica
  Map<String, dynamic>? getLatestVideoForFranchise(String franchisePath) {
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    for (var item in rawHistory) {
      final map = Map<String, dynamic>.from(item as Map);
      final savedFranchisePath = map['franchisePath']?.toString() ?? '';
      
      // Compara si la ruta coincide o si pertenece a la misma franquicia raíz
      if (savedFranchisePath == franchisePath || savedFranchisePath.startsWith(franchisePath)) {
        return map;
      }
    }
    return null;
  }
}