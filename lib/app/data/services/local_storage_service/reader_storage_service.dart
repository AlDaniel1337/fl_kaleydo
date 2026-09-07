import 'dart:collection';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReaderStorageService extends GetxService {
  late final GetStorage _box;

  static const _kReaderPositions = 'reader_chapter_positions';
  static const _kRecentMedia     = 'reader_recent_media_history';
  static const _kReadingMode     = 'reader_default_mode';
  static const _kReaderWidth     = 'reader_page_width';

  Future<ReaderStorageService> init() async {
    _box = GetStorage();
    return this;
  }

  /// Guarda o actualiza el historial reciente por franquicia y medio.
  /// Estructura guardada por cada entrada: { 'mediaType': 'manga', 'franchiseName': 'manga1', 'franchisePath': '...', 'lastChapterPath': '...', 'lastChapterTitle': '...' }
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

    // Buscar si ya existe un registro de esta misma franquicia en este medio
    history.removeWhere((item) => 
      item['mediaType'] == mediaType && item['franchisePath'] == franchisePath
    );

    // Insertar el elemento más reciente al inicio
    history.insert(0, {
      'mediaType': mediaType,
      'franchiseName': franchiseName,
      'franchisePath': franchisePath,
      'lastChapterPath': chapterPath,
      'lastChapterTitle': chapterTitle,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Mantener máximo 5 elementos por tipo de medio (o en general según prefieras)
    // Filtrar para asegurar que cada categoría mantenga su límite o aplicar un límite global por tipo
    _box.write(_kRecentMedia, history);
  }

  /// Obtiene los medios recientes filtrados por tipo de medio (ej: '_manga')
  List<Map<String, dynamic>> getRecentMediaByType(String mediaType) {
    final rawHistory = _box.read<List<dynamic>>(_kRecentMedia) ?? [];
    return rawHistory
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((item) => item['mediaType'] == mediaType)
        .take(5) // Máximo 5 por medio
        .toList();
  }

  // Métodos anteriores de páginas y configuración...
  void savePagePosition(String chapterPath, int pageIndex) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kReaderPositions) ?? {};
    final LinkedHashMap<String, int> positions = LinkedHashMap<String, int>.from(
      rawPositions.map((k, v) => MapEntry(k, v as int)),
    );

    if (positions.containsKey(chapterPath)) positions.remove(chapterPath);
    positions[chapterPath] = pageIndex;

    while (positions.length > 100) {
      positions.remove(positions.keys.first);
    }
    _box.write(_kReaderPositions, positions);
  }

  int getPagePosition(String chapterPath) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kReaderPositions) ?? {};
    return rawPositions[chapterPath] as int? ?? 0;
  }

  void setReadingMode(String mode) => _box.write(_kReadingMode, mode);
  String get readingMode => _box.read<String>(_kReadingMode) ?? 'scroll';

  void setReaderWidth(double width) => _box.write(_kReaderWidth, width);
  double get readerWidth => _box.read<double>(_kReaderWidth) ?? 1000.0;
 
  /// Obtiene el último capítulo leído de una franquicia específica
  Map<String, dynamic>? getLatestChapterForFranchise(String franchisePath) {
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