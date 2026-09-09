import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // <-- No olvides importar Get para Obx
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';

class ReaderScrollView extends StatelessWidget {
  final ReaderController controller;

  const ReaderScrollView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // El Stack envuelve al Scroll para limitar su tamaño a la pantalla visible
    return Stack(
      children: [
        // Capa inferior: El contenido desplazable
        SingleChildScrollView(
          controller: controller.scrollController,
          child: Column(
            children: controller.imagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final imagePath = entry.value;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                key: controller.pageKeys[index],
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {

                    if (wasSynchronouslyLoaded) return child;

                    // Placeholder
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: child,
                    );

                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Capa superior: El indicador flotante (cubre toda la vista y bloquea toques accidentales)
        Obx(
          () => controller.isLoadingPosition.value
              ? Container(
                  color: AppColors.background, // Usa el fondo sólido o con opacidad (.withOpacity(0.9))
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.primaryAccent,
                          strokeWidth: 4,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Reanudando última página',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}