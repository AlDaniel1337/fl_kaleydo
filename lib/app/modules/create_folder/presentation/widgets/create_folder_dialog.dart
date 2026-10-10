import 'package:flutter/material.dart';
import '../../domain/entities/folder_option.dart';
import '../../domain/usecases/create_folder_structure_usecase.dart';

class CreateFolderDialog extends StatefulWidget {
  final String parentDirectoryPath;
  final CreateFolderStructureUseCase createFolderUseCase;

  const CreateFolderDialog({
    super.key,
    required this.parentDirectoryPath,
    required this.createFolderUseCase,
  });

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  final TextEditingController _folderNameController = TextEditingController();

  final List<FolderOption> _subfolderOptions = [
    FolderOption(name: 'Anime'),
    FolderOption(name: 'Anime H'),
    FolderOption(name: 'Manga'),
    FolderOption(name: 'Manga H'),
    FolderOption(name: 'Novela visual', createExtraFolder: true, createCGSFolder: true),
    FolderOption(name: 'Manwha'),
    FolderOption(name: 'Resumen'),
    FolderOption(name: 'Juego', createExtraFolder: true, createImagesFolder: true),
  ];

  bool _isCreating = false;

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  Future<void> _createStructure() async {
    setState(() => _isCreating = true);

    try {
      final selectedNames = _subfolderOptions.where((opt) => opt.isSelected).toList();

      await widget.createFolderUseCase(
        parentPath: widget.parentDirectoryPath,
        rootName: _folderNameController.text,
        subfolderNames: selectedNames,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear estructura de carpetas'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _folderNameController,
              enabled: !_isCreating,
              decoration: const InputDecoration(
                labelText: 'Nombre de carpeta principal',
                hintText: 'Ej: MiNuevoProyecto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Selecciona las subcarpetas a incluir:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: _subfolderOptions.map((option) {
                  return CheckboxListTile(
                    title: Text(option.name),
                    value: option.isSelected,
                    dense: true,
                    enabled: !_isCreating,
                    onChanged: (bool? value) {
                      setState(() {
                        option.isSelected = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createStructure,
          child: _isCreating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Crear carpetas'),
        ),
      ],
    );
  }
}