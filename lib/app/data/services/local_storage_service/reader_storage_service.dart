// lib/app/data/services/reader_storage_service.dart

import 'dart:collection';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Servicio de almacenamiento local para las preferencias de lectura,
/// páginas guardadas e historial de cómics/mangas/libros.
class ReaderStorageService extends GetxService {
  //+ VARIABLES
  late final GetStorage _box;

  // Claves de almacenamiento
  static const String _kSettings        = 'reader_settings';
  static const String _kReaderPositions = 'reader_chapter_positions';
  static const String _kRecentMedia     = 'reader_recent_media_history';
  //!+

  //+ INICIALIZACIÓN
  /// Inicializa la caja de almacenamiento local.
  Future<ReaderStorageService> init() async {
    _box = GetStorage();
    return this;
  }
  //!+

  //+ CONFIGURACIONES Y GETTERS
  /// Guarda todas las configuraciones del lector en un solo objeto JSON.
  void saveSettings({
    required String readingMode,
    required double readerWidth,
  }) {
    final settings = {
      'readingMode': readingMode,
      'readerWidth': readerWidth,
    };
    _box.write(_kSettings, settings);
  }

  /// Establece el modo de lectura ('scroll' o 'page').
  void setReadingMode(String mode) => _saveSettingValue('readingMode', mode);

  /// Establece el ancho personalizado del visor de lectura.
  void setReaderWidth(double width) => _saveSettingValue('readerWidth', width);

  // Getters con parseo seguro
  String get readingMode =>
      _getSettingsMap()['readingMode'] as String? ?? 'scroll';

  double get readerWidth =>
      _asDouble(_getSettingsMap()['readerWidth'], defaultValue: 1000.0);
  //!+

  //+ GESTIÓN DE POSICIONES E HISTORIAL
  /// Guarda o actualiza el historial reciente por franquicia y tipo de medio.
  void saveRecentMedia({
    required String mediaType, // Ej: '_manga', 'manga'
    required String franchiseName,
    required String franchisePath,
    required String chapterPath,
    required String chapterTitle,
    required int pageIndex,
  }) {
    // 1. Guardar posición de página normal
    savePagePosition(chapterPath, pageIndex);

    // 2. Gestionar historial por franquicia y medio (máximo 5 por categoría)
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
      'lastChapterPath': chapterPath,
      'lastChapterTitle': chapterTitle,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _box.write(_kRecentMedia, history);
  }

  /// Guarda el número de página actual de un capítulo.
  void savePagePosition(String chapterPath, int pageIndex) {
    final rawPositions =
        _box.read<Map<String, dynamic>>(_kReaderPositions) ?? {};
    final LinkedHashMap<String, int> positions =
        LinkedHashMap<String, int>.from(
      rawPositions.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    );

    if (positions.containsKey(chapterPath)) positions.remove(chapterPath);
    positions[chapterPath] = pageIndex;

    while (positions.length > 100) {
      positions.remove(positions.keys.first);
    }
    _box.write(_kReaderPositions, positions);
  }

  /// Obtiene la página guardada para un capítulo (0 por defecto).
  int getPagePosition(String chapterPath) {
    final rawPositions =
        _box.read<Map<String, dynamic>>(_kReaderPositions) ?? {};
    final rawVal = rawPositions[chapterPath];
    return (rawVal as num?)?.toInt() ?? 0;
  }

  /// Obtiene los medios recientes filtrados por tipo de medio (ej: '_manga').
  List<Map<String, dynamic>> getRecentMediaByType(String mediaType) {
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    return rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((item) => item['mediaType'] == mediaType)
        .take(5)
        .toList();
  }

  /// Obtiene el último capítulo leído de una franquicia específica.
  Map<String, dynamic>? getLatestChapterForFranchise(String franchisePath) {
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