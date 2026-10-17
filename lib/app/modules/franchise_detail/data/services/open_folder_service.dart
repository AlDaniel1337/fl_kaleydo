import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OpenFolderService {
  
  /// Abre la carpeta especificada en una ventana del explorador de archivos del sistema operativo
  static Future<void> openFolder(String folderPath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [folderPath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [folderPath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [folderPath]);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir la ubicación del archivo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white);
    }
  }
}