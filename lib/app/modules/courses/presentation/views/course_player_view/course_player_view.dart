import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'widgets/widgets.index.dart';
import '../../controllers/course_player_controller.dart';

class CoursePlayerView extends GetView<CoursePlayerController> {

  static const String route = "/course_player";

  const CoursePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(controller.course.title, style: const TextStyle(color: AppColors.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
          onPressed: () => Get.back(),
        ),
      ),

      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //: PANEL IZQUIERDO: VIDEO Y RECURSOS
          Expanded(
            flex: 10,
            child: Column(
              children: [
                // Reproductor de Video
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,

                    child: Listener(
                      // Detecta la rueda del ratón (Scroll)
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent) {
                          // dy negativo = scroll hacia arriba,
                          // dy positivo = scroll hacia abajo
                          if (pointerSignal.scrollDelta.dy < 0) {
                            controller.changeVolume(10.0); // Subir volumen de 10 en 10
                          } else {
                            controller.changeVolume(-10.0); // Bajar volumen de 10 en 10
                          }
                        }
                      },

                      child: Stack(
                        children: [
                          // El reproductor nativo
                          Positioned.fill(
                            child: Video(controller: controller.videoController),
                          ),
                          
                          // Zona de clic invisible (Deja 80px libres abajo para no bloquear la barra de progreso)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: 80, 
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: controller.togglePlayPause,
                              child: Container(color: Colors.transparent),
                            ),
                          ),

                          // Indicador visual de volumen tipo TV flotante
                          VolumeIndicator(controller: controller),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Barra de Controles de Estudio
                CourseStudyControlsBar(controller: controller),
              ],
            ),
          ),

          // Línea divisoria
          Container(width: 1, color: Colors.grey.shade800),

          //: PANEL DERECHO: ÍNDICE DE LECCIONES TIPO ACORDEÓN
          Expanded(
            flex: 3,
            child: RightPanelForLessonsAndResources(controller: controller),
          ),
        ],
      ),
    );
  }
}
