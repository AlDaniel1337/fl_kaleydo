// lib/app/data/services/player_storage_service.dart

import 'dart:collection';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Servicio de almacenamiento local para la configuración del reproductor y el
/// historial de reproducción de video.
class PlayerStorageService extends GetxService {

  //+ VARIABLES
  late final GetStorage _box;

  //: Claves de almacenamiento
  static const String _kSettings    = 'player_settings';
  static const String _kPositions   = 'player_video_positions';
  static const String _kRecentMedia = 'player_recent_video_history';
  //!+



  //+ INICIALIZACIÓN
  /// Inicializa la caja de almacenamiento.
  Future<PlayerStorageService> init() async {
    _box = GetStorage();
    return this;
  }
  //!+



  //+ CONFIGURACIONES Y GETTERS
  /// Guardar todas las configuraciones del reproductor juntas en formato JSON.
  void saveSettings({
    required double speed,
    required double volume,
    required bool subtitles,
    required bool fastSeeking,
    required double brightness,
    String? audioTrackId,
  }) {
    final settings = {
      'speed': speed,
      'volume': volume,
      'subtitles': subtitles,
      'fastSeeking': fastSeeking,
      'brightness': brightness,
      'audioTrackId': audioTrackId ?? '',
      'autoResume': autoResumeEnabled,
    };
    _box.write(_kSettings, settings);
  }

  /// Habilita o deshabilita la reanudación automática del reproductor.
  void setAutoResume(bool enabled) {
    _saveSettingValue('autoResume', enabled);
  }

  // Getters con parseo numérico seguro
  double get speed           => _asDouble(_getSettingsMap()['speed'], defaultValue: 1.0);
  double get volume          => _asDouble(_getSettingsMap()['volume'], defaultValue: 100.0);
  bool get subtitlesEnabled  => _getSettingsMap()['subtitles'] as bool? ?? false;
  String? get audioTrackId   => _getSettingsMap()['audioTrackId']?.toString();
  bool get isFastSeeking     => _getSettingsMap()['fastSeeking'] as bool? ?? true;
  double get brightness      => _asDouble(_getSettingsMap()['brightness'], defaultValue: 1.0);
  bool get autoResumeEnabled => _getSettingsMap()['autoResume'] as bool? ?? true;
  //!+

  //+ GESTIÓN DE POSICIONES E HISTORIAL
  /// Guarda la última posición y actualiza el historial reciente por medio, franquicia y episodio.
  void savePosition({
    required String mediaType,     // Ej: '_anime', 'anime', 'video'
    required String franchiseName, // Ej: 'anime1'
    required String franchisePath, // Ruta de la carpeta de la franquicia
    required String videoPath,     // Ruta exacta del archivo de video
    required String videoTitle,    // Título del capítulo/episodio
    required int positionInMs,     // Posición actual en milisegundos
  }) {

    // 1. Guardar posición por archivo individual
    final rawPositions = _box.read<Map<String, dynamic>>(_kPositions) ?? {};
    final LinkedHashMap<String, int> positions = LinkedHashMap<String, int>.from(
      rawPositions.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );

    if (positions.containsKey(videoPath)) positions.remove(videoPath);
    positions[videoPath] = positionInMs;
    while (positions.length > 200) {
      positions.remove(positions.keys.first);
    }
    _box.write(_kPositions, positions);

    // 2. Gestionar historial estructurado por franquicia y tipo de medio
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    List<Map<String, dynamic>> history = rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    history.removeWhere((item) =>
        item['mediaType'] == mediaType && item['franchisePath'] == franchisePath);

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

  /// Obtiene la posición guardada de un video (0 por defecto).
  int getPosition(String videoPath) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kPositions) ?? {};
    final rawVal = rawPositions[videoPath];
    return (rawVal as num?)?.toInt() ?? 0;
  }

  /// Obtiene los medios recientes de video filtrados por tipo de medio (ej: '_anime').
  List<Map<String, dynamic>> getRecentMediaByType(String mediaType) {
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    return rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((item) => item['mediaType'] == mediaType)
        .take(5)
        .toList();
  }

  /// Obtiene el último video/episodio reproducido de una franquicia específica.
  Map<String, dynamic>? getLatestVideoForFranchise(String franchisePath) {
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    for (var item in rawHistory) {
      final map = Map<String, dynamic>.from(item as Map);
      final savedFranchisePath = map['franchisePath']?.toString() ?? '';

      if (savedFranchisePath == franchisePath ||
          savedFranchisePath.startsWith(franchisePath)) {
        return map;
      }
    }
    return null;
  }
  //!+



  //+ MÉTODOS AUXILIARES
  /// Obtiene el mapa completo de configuraciones o uno vacío por defecto.
  Map<String, dynamic> _getSettingsMap() {
    final raw = _box.read<Map<String, dynamic>>(_kSettings);
    if (raw == null) return {};
    return Map<String, dynamic>.from(raw);
  }

  /// Guarda o actualiza un valor específico dentro del JSON de configuraciones.
  void _saveSettingValue(String key, dynamic value) {
    final settings = _getSettingsMap();
    settings[key] = value;
    _box.write(_kSettings, settings);
  }

  /// Convierte valores numéricos provenientes de JSON a double de forma segura.
  double _asDouble(dynamic value, {required double defaultValue}) {
    if (value is num) return value.toDouble();
    return defaultValue;
  }
  //!+
}