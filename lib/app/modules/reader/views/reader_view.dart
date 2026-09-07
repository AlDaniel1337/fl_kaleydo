// lib/app/modules/reader/views/reader_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';
import 'widgets/reader_footer/reader_footer.dart';
import 'widgets/reader_header/reader_header.dart';
import 'widgets/reader_page_view/reader_page_view.dart';
import 'widgets/reader_scroll_view/reader_scroll_view.dart';

class ReaderView extends GetView<ReaderController> {

  static const String route = "/reader";

  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          );
        }

        //: Si no hay imágenes, mostrar un mensaje de error
        if (controller.imagePaths.isEmpty) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: const Center(
              child: Text(
                'No se encontraron imágenes en la carpeta del capítulo.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: controller.toggleControls,
          child: Stack(
            children: [
              
              //: ÁREA DE LECTURA
              Positioned.fill(
                child: controller.readingMode.value == ReadingMode.scroll
                    ? ReaderScrollView(controller: controller)
                    : ReaderPageView(controller: controller),
              ),

              //: HEADER SUPERIOR FLOTANTE
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !controller.isControlsVisible.value,
                      child: ReaderHeader(controller: controller),
                    ),
                  ),
                ),
              ),

              //: FOOTER INFERIOR FLOTANTE
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Obx(
                  () => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !controller.isControlsVisible.value,
                      child: ReaderFooter(controller: controller),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}