import 'dart:io';

import 'package:kaleydo/app/modules/create_folder/domain/entities/folder_option.dart';

import '../repositories/folder_repository.dart';

class CreateFolderStructureUseCase {
  final FolderRepository repository;

  CreateFolderStructureUseCase(this.repository);

  Future<void> call({
    required String parentPath,
    required String rootName,
    required List<FolderOption> subfolderNames,
    required List<FolderOption> extraFolderOptions,
    required String folderDetails,
    required String folderTags,
  }) async {

    var (isValid, errorMessage) = isRootFolderNameValid(rootName);
    if (!isValid) {
      throw Exception(errorMessage);
    }

    //: Paths
    final rootDirPath   = '$parentPath/$rootName';
    final extraDirPath  = '$rootDirPath/extra';
    final cgsDirPath    = '$extraDirPath/cgs';
    final imagesDirPath = '$extraDirPath/imagenes';
    final infoFilePath  = '$extraDirPath/info.txt';

    //: Crear la carpeta raíz si no existe
    if (!await repository.directoryExists(rootDirPath)) {
      await repository.createDirectory(rootDirPath);
    }

    //: Crear las subcarpetas dentro de la carpeta raíz si no existen
    for (final subfolder in subfolderNames) {

      final subDirPath = '$rootDirPath/${subfolder.name}';      
      if (!await repository.directoryExists(subDirPath)) {
        await repository.createDirectory(subDirPath);
          
          //: Crear la carpeta "extra" si no existe
          // Juntar todas las opciones de subcarpetas dentro de "extra"
          if (!await repository.directoryExists(extraDirPath)) {
            await repository.createDirectory(extraDirPath);
            
            //: Crear la carpeta "cgs" dentro de "extra" si la opción está activada
            if (extraFolderOptions.any((opt) => opt.name == 'CGs' && opt.isSelected) && !await repository.directoryExists(cgsDirPath)) {
              if (!await repository.directoryExists(cgsDirPath)) {
                await repository.createDirectory(cgsDirPath);
              }
            }
            
            //: Crear la carpeta "images" dentro de "extra" si la opción está activada
            if (extraFolderOptions.any((opt) => opt.name == 'Imagenes' && opt.isSelected) && !await repository.directoryExists(imagesDirPath)) {
              await repository.createDirectory(imagesDirPath);
            }

            //: Crear archivo "info.txt" dentro de "extra" si no existe
            if (!await repository.fileExists(infoFilePath)) {
              await repository.createFile(infoFilePath);
            }

            //: Agrega la información inicial al archivo "info.txt"
            if (await repository.fileExists(infoFilePath)) {
              final file = File(infoFilePath);
              await file.writeAsString(
                '$folderDetails\n'
                '---\n'
                '$folderTags',
              mode: FileMode.write
              );
            }
          
          
        }
      }
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