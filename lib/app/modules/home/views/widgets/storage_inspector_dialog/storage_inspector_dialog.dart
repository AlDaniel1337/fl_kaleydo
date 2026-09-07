import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/controllers/storage_inspector_controller.dart';

void showStorageInspectorModal(BuildContext context) {
  final controller = Get.put(StorageInspectorController());

  Get.dialog(
    Dialog(
      backgroundColor: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Inspector y Limpieza de Almacenamiento',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () {
                    Get.delete<StorageInspectorController>();
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 8),

            // Lista dinámica
            Expanded(
              child: Obx(() {
                if (controller.storedKeys.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay datos almacenados actualmente.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.storedKeys.length,
                  itemBuilder: (context, index) {
                    final key = controller.storedKeys[index];
                    final value = controller.storedData[key];

                    // Evaluamos si contiene múltiples elementos (List o Map)
                    final bool isList = value is List;
                    final bool isMap = value is Map;
                    final bool hasMultipleItems = (isList && value.isNotEmpty) || (isMap && value.isNotEmpty);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabecera de la Llave
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key,
                                style: const TextStyle(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 20),
                                tooltip: 'Eliminar toda la clave',
                                onPressed: () => controller.removeKey(key),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Contenido desglosado si es una Lista o un Mapa
                          if (hasMultipleItems) ...[
                            const Text(
                              'Elementos guardados (elimina de forma individual):',
                              style: TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: isList ? (value as List).length : (value as Map).keys.length,
                                itemBuilder: (subContext, subIndex) {
                                  if (isList) {
                                    final item = (value as List)[subIndex];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$item',
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                            tooltip: 'Eliminar este elemento',
                                            onPressed: () => controller.removeListItem(key, subIndex),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    final mapKey = (value as Map).keys.elementAt(subIndex);
                                    final mapVal = value[mapKey];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$mapKey ➔ $mapVal',
                                              style: const TextStyle(color: Colors.white, fontSize: 12),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
                                            tooltip: 'Eliminar este registro',
                                            onPressed: () => controller.removeMapKey(key, mapKey),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ] else ...[
                            Text(
                              '$value',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Botón inferior para limpiar todo
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  icon: const Icon(Icons.delete_forever_rounded),
                  label: const Text('Limpiar Todo el Storage'),
                  onPressed: () {
                    Get.defaultDialog(
                      title: '¿Vaciar almacenamiento?',
                      middleText: 'Se eliminarán todas las configuraciones, favoritos e historiales guardados.',
                      backgroundColor: AppColors.cardBackground,
                      titleStyle: const TextStyle(color: Colors.white),
                      middleTextStyle: const TextStyle(color: Colors.white70),
                      textConfirm: 'Sí, vaciar',
                      textCancel: 'Cancelar',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        controller.clearAllStorage();
                        Get.back();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}