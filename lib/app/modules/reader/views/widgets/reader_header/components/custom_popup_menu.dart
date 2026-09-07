import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';


class CustomPopupMenu extends StatelessWidget {
  const CustomPopupMenu({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
      tooltip: 'Ancho de la ventana',
      color: AppColors.cardBackground,
      onSelected: controller.setWindowWidth,
      itemBuilder: (context) => controller.windowWidthOptions.entries.map((entry) {
        final isSelected = controller.currentWindowWidth.value == entry.key;
        return PopupMenuItem<double>(
          value: entry.key,
          child: Row(
            children: [
              Icon(
                Icons.check,
                color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                entry.value,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryAccent : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
