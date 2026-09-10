import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';
import 'package:kaleydo/app/modules/reader/views/widgets/reader_scroll_view/components/resuming_indicator.dart';

class ReaderScrollView extends StatelessWidget {
  final ReaderController controller;

  const ReaderScrollView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //: Capa inferior: El contenido desplazable
        SingleChildScrollView(
          controller: controller.scrollController,
          padding: EdgeInsets.zero,
          child: Column(
            children: controller.imagePaths.asMap().entries.map((entry) {
              final index = entry.key;
              final imagePath = entry.value;

              return Transform.translate(
                // Superpone 0.5 píxeles cada imagen sobre la anterior para tapar la brecha
                offset: Offset(0, index == 0 ? 0 : -0.8), 
                child: Image.file(
                  File(imagePath),
                  key: controller.pageKeys[index],
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  // Ayuda a que los bordes de la imagen no tengan suavizado transparente
                  filterQuality: FilterQuality.low, 
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;

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

        //: Capa superior: El indicador flotante (cubre toda la vista y bloquea toques accidentales)
        Obx( () => controller.isLoadingPosition.value
          ? const ResumingIndicator()
          : const SizedBox.shrink(),
        ),
      ],
    );
  }
}