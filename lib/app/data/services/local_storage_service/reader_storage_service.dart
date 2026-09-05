// lib/app/data/services/reader_storage_service.dart

import 'dart:collection';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ReaderStorageService extends GetxService {
  late final GetStorage _box;

  static const _kReaderPositions = 'reader_chapter_positions';
  static const _kReadingMode     = 'reader_default_mode';

  Future<ReaderStorageService> init() async {
    _box = GetStorage();
    return this;
  }

  /// Guarda la última página/posición alcanzada en un capítulo manteniendo máximo 100 registros.
  void savePagePosition(String chapterPath, int pageIndex) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kReaderPositions) ?? {};

    final LinkedHashMap<String, int> positions = LinkedHashMap<String, int>.from(
      rawPositions.map((k, v) => MapEntry(k, v as int)),
    );

    if (positions.containsKey(chapterPath)) {
      positions.remove(chapterPath);
    }

    positions[chapterPath] = pageIndex;

    // Límite de historial de lectura
    while (positions.length > 100) {
      positions.remove(positions.keys.first);
    }

    _box.write(_kReaderPositions, positions);
  }

  /// Obtiene la página guardada de un capítulo (0 por defecto).
  int getPagePosition(String chapterPath) {
    final rawPositions = _box.read<Map<String, dynamic>>(_kReaderPositions) ?? {};
    return rawPositions[chapterPath] as int? ?? 0;
  }

  /// Preferencia global de modo de lectura: 'scroll' o 'page'
  void setReadingMode(String mode) => _box.write(_kReadingMode, mode);
  String get readingMode => _box.read<String>(_kReadingMode) ?? 'scroll';
}