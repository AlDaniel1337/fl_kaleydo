import 'package:flutter/material.dart';
import '../../domain/entities/folder_option.dart';
import '../../domain/usecases/edit_folder_data_usecase.dart';

class EditFolderDataDialog extends StatefulWidget {

  final String parentDirectoryPath;
  final EditFolderDataUseCase editFolderDataUseCase;
  final String currentFolderName;

  const EditFolderDataDialog({
    super.key,
    required this.parentDirectoryPath,
    required this.editFolderDataUseCase,
    required this.currentFolderName,

  });

  @override
  State<EditFolderDataDialog> createState() => _EditFolderDataDialogState();
}

class _EditFolderDataDialogState extends State<EditFolderDataDialog> {

  final TextEditingController _folderDetailsController = TextEditingController();
  final TextEditingController _folderTagsController = TextEditingController();

  final List<FolderOption> _extraFolderOptions = ExtraFolderNames.values.map(
    (e) => FolderOption(name: e.name, isSelected: e.isSelected)
  ).toList();

  bool _isCreating = false;

  @override
  void dispose() {
    _folderDetailsController.dispose();
    _folderTagsController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final dialogWidth = MediaQuery.of(context).size.width * 0.25;

    return AlertDialog(
      title: Text(widget.currentFolderName),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          //+ Columna Izquierda
          // Opciones Extra
          SizedBox(
            width: dialogWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          
          
          //+ Columna Derecha
          // Detalles y Etiquetas
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
            : const Text('Actualizar'),
        ),
      ],
    );
  }

  



  // ==========================================
  //: Funciones
  // ==========================================

  Future<void> _createStructure() async {

    setState(() => _isCreating = true);

    try {     
      await widget.editFolderDataUseCase(
        folderPath: widget.parentDirectoryPath,
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



  void _onExtraFolderChanged(FolderOption option, bool value) {
    setState(() {
      option.isSelected = value;
    });
  }
  
}



// ==========================================
//: Subcomponentes
// ==========================================

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
          onChanged: onEtiquetaChanged,
        ),
      ],
    );
  }

  void onEtiquetaChanged(String value) {
    // Remplazar los saltos (\n) y los dobles espacios por comas ","
    value = value.replaceAll('\n', ', ').replaceAll('  ', ', ');
    
    // Ajustar texto para que solo sea un renglón por etiqueta
    value = value.split(',').map((e) => e.trim()).join(', ');
    
    tagsController.text = value;
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
        
        bool enabled = option.name != ExtraFolderNames.info.name;
        
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