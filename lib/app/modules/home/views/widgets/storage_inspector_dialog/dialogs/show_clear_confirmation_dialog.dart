import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/state_manager.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

void showClearConfirmationDialog(
  BuildContext context,
  void Function() onConfirm,
) {
    Get.defaultDialog(
      title: '¿Vaciar almacenamiento?',
      middleText:
          'Se eliminarán todas las configuraciones, favoritos e historiales guardados.',
      backgroundColor: AppColors.cardBackground,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textConfirm: 'Sí, vaciar',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      onConfirm: () {
        onConfirm();
        Get.back();
      },
    );
  }