import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:kaleydo/app/data/models/config_model.dart';

class ConfigController extends GetxController {

  final Rx<ConfigModel> config = ConfigModel.defaultConfig().obs;
  final RxBool isLoading = true.obs;
  final RxBool isRootDirectoryValid = false.obs;

  late File _configFile;

  @override
  void onInit() {
    super.onInit();
    loadConfiguration();
  }



  ///+ Carga la configuración desde el archivo config.json o crea uno por defecto si no existe.
  Future<void> loadConfiguration() async {
    try {

      //: Cargar la configuración desde el archivo
      isLoading.value = true;
      final appSupportDir = await getApplicationSupportDirectory();
      _configFile = File(p.join(appSupportDir.path, 'config.json'));

      //: Si la configuración no existe, crear una por defecto
      if (await _configFile.exists()) {
        final content = await _configFile.readAsString();
        final jsonMap = json.decode(content);
        config.value = ConfigModel.fromJson(jsonMap);
      } else {
        await _saveConfiguration(ConfigModel.defaultConfig());
      }

      _validateRootDirectory();
    } catch (e) {
      Get.snackbar(
        'Error de Configuración',
        'No se pudo cargar la configuración: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  //!+



  ///+ Permite al usuario seleccionar la carpeta raíz de Kaleydo.
  Future<void> selectRootDirectory() async {
    
    //: Abrir el selector de carpetas para que el usuario elija la carpeta raíz de Kaleydo.
    final String? selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Selecciona la carpeta raíz de Kaleydo',
      initialDirectory: config.value.rootFolderPath.isNotEmpty
          ? config.value.rootFolderPath
          : null,
    );

    //: Si el usuario seleccionó una carpeta, actualizar la configuración y validar la ruta.
    if (selectedPath != null && selectedPath.isNotEmpty) {
      config.update((val) {
        val?.rootFolderPath = selectedPath;
      });
      await _saveConfiguration(config.value);
      _validateRootDirectory();

      Get.snackbar(
        'Carpeta Raíz Actualizada',
        'Nueva ruta: $selectedPath',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  //!+



  ///+ Guarda la configuración actual en el archivo config.json.
  Future<void> _saveConfiguration(ConfigModel newConfig) async {
    try {
      if (!await _configFile.parent.exists()) {
        await _configFile.parent.create(recursive: true);
      }
      await _configFile.writeAsString(newConfig.toRawJson());
    } catch (e) {
      Get.snackbar(
        'Error al Guardar',
        'No se pudo escribir en config.json: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  //!+



  ///+ Valida si la carpeta raíz de Kaleydo existe y actualiza el estado correspondiente.
  void _validateRootDirectory() {
    final path = config.value.rootFolderPath;
    if (path.isEmpty) {
      isRootDirectoryValid.value = false;
    } else {
      final dir = Directory(path);
      isRootDirectoryValid.value = dir.existsSync();
    }
  }
  //!+



  /// Obtiene la ruta de la carpeta raíz de Kaleydo.
  String get rootPath => config.value.rootFolderPath;
}