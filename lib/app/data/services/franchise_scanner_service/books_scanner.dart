import 'dart:io';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:path/path.dart' as p;
import 'find_cover.dart';

/// Servicio para escanear libros dentro de un directorio.
class BooksScannerService {

  static const _validExtensions = ['.pdf', '.epub', '.md'];

  static Future<List<FranchiseItemModel>> scanBooks(Directory booksDir) async {

    final List<FranchiseItemModel> books = [];
    final entities = await booksDir.list().toList();

    //: Libros directos en la raíz de la carpeta (ej. Novelas/Volumen_01.pdf)
    final directFiles = entities.whereType<File>().where((f) {
      final ext = p.extension(f.path).toLowerCase();
      return _validExtensions.contains(ext);
    }).toList();
    
    for (var file in directFiles) {
      books.add(FranchiseItemModel(
        title: p.basenameWithoutExtension(file.path),
        path: file.path,
        pagePaths: [file.path],
      ));
    }

    //: Libros organizados en subcarpetas (ej. Novelas/Volumen 1/Volumen_1.pdf)
    for (var subDir in entities.whereType<Directory>()) {
      final subFiles = await subDir.list().toList();
      for (var file in subFiles.whereType<File>()) {
        final ext = p.extension(file.path).toLowerCase();
        if (_validExtensions.contains(ext)) {
          books.add(FranchiseItemModel(
            title: '${p.basename(subDir.path)} - ${p.basenameWithoutExtension(file.path)}',
            path: file.path,
            pagePaths: [file.path],
          ));
        }
      }
    }

    books.sort((a, b) => naturalSortCompare(a.title, b.title));
    return books;
  }
}