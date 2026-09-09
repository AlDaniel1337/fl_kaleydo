import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;

class PdfCacheService {
  /// Procesa un archivo PDF, extrae sus páginas como imágenes si no están en caché,
  /// y devuelve la lista de rutas de las imágenes ordenadas.
  static Future<List<String>> getOrExtractPdfPages(String pdfPath) async {
    final file = File(pdfPath);
    if (!await file.exists()) return [];

    // Definir una carpeta de caché única para este PDF basada en su nombre y última modificación
    final appSupportDir = await getApplicationSupportDirectory();
    final fileName = file.uri.pathSegments.last.replaceAll(RegExp(r'\.[^$]*$'), '');
    final lastModified = await file.lastModified();
    
    final cacheDir = Directory('${appSupportDir.path}/pdf_cache/${fileName}_${lastModified.millisecondsSinceEpoch}');

    // Si ya existe el directorio con las imágenes extraídas, las retornamos directamente
    if (await cacheDir.exists()) {
      final List<FileSystemEntity> entities = cacheDir.listSync();
      final List<String> imagePaths = entities
          .whereType<File>()
          .where((e) => e.path.endsWith('.png'))
          .map((e) => e.path)
          .toList();
      
      if (imagePaths.isNotEmpty) {
        // Ordenar estrictamente por el nombre del archivo
        imagePaths.sort((a, b) => _naturalSort(a, b));
        return imagePaths;
      }
    }

    // Si no existe caché, procedemos a abrir el PDF y renderizar sus páginas
    await cacheDir.create(recursive: true);
    final List<String> extractedImagePaths = [];

    pdfx.PdfDocument? document;
    try {
      document = await pdfx.PdfDocument.openFile(pdfPath);
      
      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        
        final pageImage = await page.render(
          width: page.width * 1.5,
          height: page.height * 1.5,
          format: pdfx.PdfPageImageFormat.png,
        );

        if (pageImage != null) {
          final pageNumberStr = i.toString().padLeft(4, '0');
          final imagePath = '${cacheDir.path}/page_$pageNumberStr.png';
          final imageFile = File(imagePath);
          await imageFile.writeAsBytes(pageImage.bytes);
          extractedImagePaths.add(imagePath);
        }
        
        await page.close();
      }
    } finally {
      await document?.close();
    }

    extractedImagePaths.sort((a, b) => _naturalSort(a, b));
    return extractedImagePaths;
  }

  static int _naturalSort(String a, String b) {
    // Extraer únicamente el nombre del archivo para evitar interferencias de números en las rutas o timestamps
    final nameA = a.split(Platform.pathSeparator).last;
    final nameB = b.split(Platform.pathSeparator).last;

    final regExp = RegExp(r'(\d+)');
    final matchA = regExp.firstMatch(nameA);
    final matchB = regExp.firstMatch(nameB);
    if (matchA != null && matchB != null) {
      int numA = int.parse(matchA.group(0)!);
      int numB = int.parse(matchB.group(0)!);
      return numA.compareTo(numB);
    }
    return nameA.compareTo(nameB);
  }
}