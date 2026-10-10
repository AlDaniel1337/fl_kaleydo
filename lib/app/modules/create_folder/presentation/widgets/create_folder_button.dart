import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/create_folder/data/datasources/folder_local_data_source.dart';
import 'package:kaleydo/app/modules/create_folder/data/repositories/folder_repository_impl.dart';
import 'package:kaleydo/app/modules/create_folder/domain/usecases/create_folder_structure_usecase.dart';
import 'package:kaleydo/app/modules/create_folder/presentation/widgets/create_folder_dialog.dart';

final _dataSource = FolderLocalDataSource();
final _repository = FolderRepositoryImpl(_dataSource);
final _useCase    = CreateFolderStructureUseCase(_repository);

class CreateFolderButton extends StatelessWidget {
  final String currentDirectoryPath;

  const CreateFolderButton({
    super.key,
    required this.currentDirectoryPath,
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      icon: const Icon(Icons.create_new_folder, color: AppColors.textSecondary),
      tooltip: 'Crear nueva carpeta',
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => CreateFolderDialog(
            parentDirectoryPath: currentDirectoryPath,
            createFolderUseCase: _useCase,
          ),
        );

        if (result == true && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Estructura creada correctamente')),
          );
        }
      },
    );
  }
}