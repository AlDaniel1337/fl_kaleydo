// lib/app/modules/main/controllers/storage_inspector_controller.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Controlador para inspeccionar y manipular el almacenamiento local usando GetStorage.
class StorageInspectorController extends GetxController {
  final GetStorage _box = GetStorage();
  
  final RxList<String> storedKeys = <String>[].obs;
  final RxMap<String, dynamic> storedData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadStorageData();
  }

  /// Carga los datos actuales del almacenamiento local en las variables reactivas `storedKeys` y `storedData`.
  void loadStorageData() {
    final keys = _box.getKeys();
    if (keys != null) {
      final listKeys = keys.cast<String>().toList();
      storedKeys.assignAll(listKeys);
      
      final map = <String, dynamic>{};
      for (var key in listKeys) {
        map[key] = _box.read(key);
      }
      storedData.assignAll(map);
    } else {
      storedKeys.clear();
      storedData.clear();
    }
  }

  /// Elimina una llave completa
  void removeKey(String key) {
    _box.remove(key);
    loadStorageData();
  }

  /// Elimina un elemento específico dentro de una Lista almacenada (ej: un favorito de la lista)
  void removeListItem(String key, int index) {
    final dynamic value = _box.read(key);
    if (value is List) {
      final updatedList = List.from(value);
      if (index >= 0 && index < updatedList.length) {
        updatedList.removeAt(index);
        _box.write(key, updatedList);
        loadStorageData();
      }
    }
  }

  /// Elimina una clave específica dentro de un Mapa almacenado (ej: la ruta de un video/capítulo en el historial)
  void removeMapKey(String key, dynamic mapKey) {
    final dynamic value = _box.read(key);
    if (value is Map) {
      final updatedMap = Map.from(value);
      if (updatedMap.containsKey(mapKey)) {
        updatedMap.remove(mapKey);
        _box.write(key, updatedMap);
        loadStorageData();
      }
    }
  }

  void clearAllStorage() {
    _box.erase();
    loadStorageData();
  }
}