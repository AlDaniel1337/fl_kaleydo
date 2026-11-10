import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
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
  final TextEditingController _folderDetailsController = TextEditingController();
  final TextEditingController _folderTagsController = TextEditingController();

  final List<FolderOption> _subfolderOptions = FolderNames.values.map((e) => FolderOption(name: e.name, isSelected: e.isSelected)).toList();

  final List<FolderOption> _extraFolderOptions = ExtraFolderNames.values.map((e) => FolderOption(name: e.name, isSelected: e.isSelected)).toList();

  bool _isCreating = false;

  @override
  void dispose() {
    _folderNameController.dispose();
    _folderDetailsController.dispose();
    _folderTagsController.dispose();
    super.dispose();
  }

  void _onSubfolderChanged(FolderOption option, bool value) {
    setState(() {
      option.isSelected = value;

      // Sincroniza la casilla 'Imagenes' de _extraFolderOptions si cambia 'Juego'
      if (option.name == FolderNames.juego.name) {
        final index = _extraFolderOptions.indexWhere(
          (opt) => opt.name == ExtraFolderNames.imagenes.name
        );

        if (index != -1) {
          _extraFolderOptions[index].isSelected = value;
        }
      }
      
      if (option.name == FolderNames.novelaVisual.name) {
        final index = _extraFolderOptions.indexWhere(
          (opt) => opt.name == ExtraFolderNames.cgs.name
        );

        if (index != -1) {
          _extraFolderOptions[index].isSelected = value;
        }
      }
    });
  }

  void _onExtraFolderChanged(FolderOption option, bool value) {
    setState(() {
      option.isSelected = value;
    });
  }

  Future<void> _createStructure() async {

    // Revisa que se haya seleccionado al menos una subcarpeta
    if (_subfolderOptions.every((opt) => !opt.isSelected)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar al menos una subcarpeta')),
        );
      }
      return;
    }

    setState(() => _isCreating = true);

    try {
      final selectedNames = _subfolderOptions.where((opt) => opt.isSelected).toList();

      await widget.createFolderUseCase(
        parentPath: widget.parentDirectoryPath,
        rootName: _folderNameController.text,
        subfolderNames: selectedNames,
        folderDetails: _folderDetailsController.text,
        folderTags: _folderTagsController.text,
        extraFolderOptions: _extraFolderOptions,
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
    final dialogWidth = MediaQuery.of(context).size.width * 0.25;

    return AlertDialog(
      title: const Text('Crear estructura de carpetas'),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          //+ Columna Izquierda: 
          // Nombre de carpeta + Opciones de subcarpetas
          SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _folderNameController,
                  enabled: !_isCreating,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de carpeta principal',
                    hintText: 'Ej: Contenido Nuevo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Selecciona las subcarpetas a incluir:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Flexible(
                  child: SubfolderSelectionList(
                    options: _subfolderOptions,
                    isEnabled: !_isCreating,
                    onOptionChanged: _onSubfolderChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          //!+

          //+ Columna Derecha:
          // Detalles, Etiquetas y Opciones Extra
          SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                FolderFormFields(
                  detailsController: _folderDetailsController,
                  tagsController: _folderTagsController,
                  isEnabled: !_isCreating,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Selecciona el contenido de la carpeta "extra":',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Flexible(
                  child: ExtraFolderSelectionList(
                    options: _extraFolderOptions,
                    isEnabled: !_isCreating,
                    onOptionChanged: _onExtraFolderChanged,
                  ),
                ),
              ],
            ),
          ),
          //!+
        ],
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
              : const Text('Crear carpeta(s)'),
        ),
      ],
    );
  }
}



// ==========================================
//: Subcomponentes
// ==========================================

/// Componente para la lista de selección de subcarpetas principales
class SubfolderSelectionList extends StatelessWidget {
  final List<FolderOption> options;
  final bool isEnabled;
  final void Function(FolderOption option, bool value) onOptionChanged;

  const SubfolderSelectionList({
    super.key,
    required this.options,
    required this.isEnabled,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: options.map((option) {
        return CheckboxListTile(
          title: Text(option.name),
          value: option.isSelected,
          dense: true,
          enabled: isEnabled,
          onChanged: (bool? value) {
            onOptionChanged(option, value ?? false);
          },
        );
      }).toList(),
    );
  }
}



/// Componente para la lista de selección de carpetas extra
class ExtraFolderSelectionList extends StatelessWidget {
  final List<FolderOption> options;
  final bool isEnabled;
  final void Function(FolderOption option, bool value) onOptionChanged;

  const ExtraFolderSelectionList({
    super.key,
    required this.options,
    required this.isEnabled,
    required this.onOptionChanged,
  });

  @override
  Widget build(BuildContext context) {


    return ListView(
      shrinkWrap: true,
      children: options.map((option) {
        
        bool enabled = option.name == ExtraFolderNames.guia.name
          ? isEnabled 
          : false;
        
        return CheckboxListTile(
          title: Text(option.name),
          value: option.isSelected,
          dense: true,
          enabled: enabled,
          onChanged: (bool? value) {
            onOptionChanged(option, value ?? false);
          },
        );
      }).toList(),
    );
  }
}



/// Componente para los campos de texto de detalles y etiquetas
class FolderFormFields extends StatelessWidget {
  final TextEditingController detailsController;
  final TextEditingController tagsController;
  final bool isEnabled;

  const FolderFormFields({
    super.key,
    required this.detailsController,
    required this.tagsController,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: detailsController,
          enabled: isEnabled,
          decoration: const InputDecoration(
            labelText: 'Sinopsis, Descripción y/o Detalles',
            hintText: 'Ej: Contenido de la carpeta',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: tagsController,
          enabled: isEnabled,
          decoration: const InputDecoration(
            labelText: 'Etiquetas (separadas por comas)',
            hintText: 'Ej: Etiqueta1, Etiqueta2, etc.',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}