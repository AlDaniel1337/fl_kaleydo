import 'package:kaleydo/app/modules/create_folder/domain/entities/folder_option.dart';

import '../repositories/folder_repository.dart';

class CreateFolderStructureUseCase {
  final FolderRepository repository;

  CreateFolderStructureUseCase(this.repository);

  bool isValidWindowsFolderName(String name) {
    final invalidChars = RegExp(r'[<>:"/\\|?*]');
    return !invalidChars.hasMatch(name);
  }

  Future<void> call({
    required String parentPath,
    required String rootName,
    required List<FolderOption> subfolderNames,
  }) async {

    // Validar el nombre de la carpeta raíz antes de crearla
    if (rootName.trim().isEmpty) {
      throw Exception('Ingresa un nombre para la carpeta raíz');
    }

    // Validar el nombre de la carpeta raíz según las reglas de Windows
    if (!isValidWindowsFolderName(rootName)) {
      throw Exception('El nombre contiene caracteres inválidos (< > : " / \\ | ? *)');
    }

    // Crear la carpeta raíz si no existe
    final rootDirPath = '$parentPath/$rootName'; // O mediante un helper de path
    if (!await repository.directoryExists(rootDirPath)) {
      await repository.createDirectory(rootDirPath);
    }

    // Crear las subcarpetas dentro de la carpeta raíz si no existen
    for (final subfolder in subfolderNames) {

      final subDirPath = '$rootDirPath/${subfolder.name}';      
      if (!await repository.directoryExists(subDirPath)) {
        await repository.createDirectory(subDirPath);
        
        if (subfolder.createExtraFolder) {
          final extraDirPath = '$rootDirPath/${subfolder.name}/extra';
          if (!await repository.directoryExists(extraDirPath)) {
            await repository.createDirectory(extraDirPath);
            
            if (subfolder.createCGSFolder) {
              final cgsDirPath = '$rootDirPath/${subfolder.name}/extra/cgs';
              if (!await repository.directoryExists(cgsDirPath)) {
                await repository.createDirectory(cgsDirPath);
              }
            }
            if (subfolder.createImagesFolder) {
              final imagesDirPath = '$rootDirPath/${subfolder.name}/extra/images';
              if (!await repository.directoryExists(imagesDirPath)) {
                await repository.createDirectory(imagesDirPath);
              }
            }
          
          }
        }
      }
    }
  }
}