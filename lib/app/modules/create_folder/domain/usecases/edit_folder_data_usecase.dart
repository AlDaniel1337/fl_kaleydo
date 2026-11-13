import 'dart:io';

import 'package:kaleydo/app/modules/create_folder/domain/entities/folder_option.dart';

import '../repositories/folder_repository.dart';

class EditFolderDataUseCase {
  final FolderRepository repository;

  EditFolderDataUseCase(this.repository);

  Future<void> call({
    required String folderPath,
    required List<FolderOption> extraFolderOptions,
    required String folderDetails,
    required String folderTags,
  }) async {


    //: Paths
    final extraDirPath  = '$folderPath/extra';
    final cgsDirPath    = '$extraDirPath/cgs';
    final imagesDirPath = '$extraDirPath/imagenes';
    final infoFilePath  = '$extraDirPath/info.txt';

    //: Crear la carpeta "extra" dentro de la subcarpeta si no existe
    if (!await repository.directoryExists(extraDirPath)) {
      await repository.createDirectory(extraDirPath);
    }

    //: Crear las subcarpetas dentro de la carpeta "extra" si no existen
    if (extraFolderOptions.any((opt) => opt.name == 'CGs' && opt.isSelected) && !await repository.directoryExists(cgsDirPath)) {
      await repository.createDirectory(cgsDirPath);
    }
  
    if (extraFolderOptions.any((opt) => opt.name == 'Imagenes' && opt.isSelected) && !await repository.directoryExists(imagesDirPath)) {
      await repository.createDirectory(imagesDirPath);
    }

    if (!await repository.fileExists(infoFilePath)) {
      await repository.createFile(infoFilePath);
    }

    if (await repository.fileExists(infoFilePath)) {
      final file = File(infoFilePath);

      // Limpiar el contenido del archivo antes de escribir la nueva información
      await file.writeAsString('', mode: FileMode.write);

      // Escribir la nueva información en el archivo
      await file.writeAsString(
        '$folderDetails\n'
        '---\n'
        '$folderTags',
        mode: FileMode.write
      );
    }

  }



  /// Valida si el nombre de la carpeta raíz es válido en Windows.
  (bool, String) isRootFolderNameValid(String name) {
   
    if(name.trim().isEmpty){
      return (false, 'Ingresa un nombre para la carpeta raíz');
    }

    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    if(invalidChars.hasMatch(name)) {
      return (false, 'El nombre contiene caracteres inválidos');
    }

    return (true, 'Nombre válido');
  }
}