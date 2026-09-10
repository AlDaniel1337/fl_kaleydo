import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/controllers/storage_inspector_controller.dart';
import 'package:kaleydo/app/modules/home/views/widgets/storage_inspector_dialog/components/components.index.dart';
import 'package:kaleydo/app/modules/home/views/widgets/storage_inspector_dialog/dialogs/show_clear_confirmation_dialog.dart';

/// Muestra el modal del inspector de almacenamiento local.
void showStorageInspectorModal(BuildContext context) {

  Get.put(StorageInspectorController());

  Get.dialog(
    PopScope(

      // Maneja el evento de retroceso del modal.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && Get.isRegistered<StorageInspectorController>()) {
          Get.delete<StorageInspectorController>();
        }
      },

      child: Dialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: const _StorageInspectorView(),
        ),
      ),
    ),

  );
}

//+ VISTA PRINCIPAL
class _StorageInspectorView extends GetView<StorageInspectorController> {
  const _StorageInspectorView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //: CABECERA
        StorageInspectorHeader(
          onClose: () => Get.back(),
        ),
        const Divider(color: AppColors.cardBorder),
        const SizedBox(height: 8),

        //: LISTA DINÁMICA DE DATOS
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
                return StorageKeyCard(
                  keyName: key,
                  value: value,
                  onRemoveKey: () => controller.removeKey(key),
                  onRemoveListItem: (i) => controller.removeListItem(key, i),
                  onRemoveMapKey: (k) => controller.removeMapKey(key, k),
                );
              },
            );
          }),
        ),
        //!+

        const SizedBox(height: 16),

        //: FOOTER
        StorageInspectorFooter(
          onClearAll: () => showClearConfirmationDialog(
            context, 
            () => controller.clearAllStorage()
          ),
        ),
      ],
    );
  }
}
//!+