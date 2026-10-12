import 'dart:io';

mixin ChapterScannerMixin {

  /// Escanea de forma asíncrona imágenes de un directorio y las devuelve ordenadas de forma natural.
  Future<List<String>> scanChapterDirectory(String directoryPath) async {
    final Directory dir = Directory(directoryPath);

    if (!await dir.exists()) return [];

    final List<FileSystemEntity> entities = await dir.list().toList();
    final List<String> files = entities
        .whereType<File>()
        .map((e) => e.path)
        .where((path) {
          final ext = path.toLowerCase();
          return ext.endsWith('.png') ||
              ext.endsWith('.jpg')    ||
              ext.endsWith('.jpeg')   ||
              ext.endsWith('.webp');
        })
        .toList();

    files.sort(_naturalCompare);
    return files;
  }

  /// Compara dos cadenas de texto considerando secuencias numéricas integradas.
  int _naturalCompare(String a, String b) {
    final String fileNameA = a.split(RegExp(r'[/\\]')).last;
    final String fileNameB = b.split(RegExp(r'[/\\]')).last;

    final RegExp regExp = RegExp(r'(\d+|\D+)');
    final Iterable<Match> matchesA = regExp.allMatches(fileNameA);
    final Iterable<Match> matchesB = regExp.allMatches(fileNameB);

    final Iterator<Match> itA = matchesA.iterator;
    final Iterator<Match> itB = matchesB.iterator;

    while (itA.moveNext() && itB.moveNext()) {
      final String tokenA = itA.current.group(0)!;
      final String tokenB = itB.current.group(0)!;

      final int? numA = int.tryParse(tokenA);
      final int? numB = int.tryParse(tokenB);

      if (numA != null && numB != null) {
        final int numCompare = numA.compareTo(numB);
        if (numCompare != 0) return numCompare;
      } else {
        final int strCompare =
            tokenA.toLowerCase().compareTo(tokenB.toLowerCase());
        if (strCompare != 0) return strCompare;
      }
    }

    return fileNameA.length.compareTo(fileNameB.length);
  }
}