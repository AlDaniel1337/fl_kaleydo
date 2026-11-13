import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/create_folder/data/datasources/folder_local_data_source.dart';
import 'package:kaleydo/app/modules/create_folder/data/repositories/folder_repository_impl.dart';
import 'package:kaleydo/app/modules/create_folder/domain/usecases/edit_folder_data_usecase.dart';
import 'package:kaleydo/app/modules/create_folder/presentation/widgets/edit_folder_data_dialog.dart';

final _dataSource = FolderLocalDataSource();
final _repository = FolderRepositoryImpl(_dataSource);
final _useCase    = EditFolderDataUseCase(_repository);

class CreateSubFolderButton extends StatelessWidget {
  final String currentDirectoryPath;
   
  const CreateSubFolderButton({
    super.key, 
    required this.currentDirectoryPath,
  });

  @override
  Widget build(BuildContext context) {

    final currentFolderName = currentDirectoryPath.split('\\').last;

    return IconButton(
      icon: const Icon(Icons.edit, color: AppColors.textSecondary),
      tooltip: 'Actualizar información',
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => EditFolderDataDialog(
            parentDirectoryPath: currentDirectoryPath,
            editFolderDataUseCase: _useCase,
            currentFolderName: currentFolderName,
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