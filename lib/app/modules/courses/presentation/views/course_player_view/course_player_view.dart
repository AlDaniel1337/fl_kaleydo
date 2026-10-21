import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/data/services/keyboard_events.service.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/course_player_view/widgets/show_notes_modal.dart';
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
        actions: [
          ShowNotesModal(controller: controller),
          const SizedBox(width: 16),
        ],
      ),
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) => KeyboardEventsService.playerEventHandler(
          node: node,
          event: event,
          controller: controller,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            //: PANEL IZQUIERDO: VIDEO Y RECURSOS
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.black,
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            if (pointerSignal.scrollDelta.dy < 0) {
                              controller.changeVolume(10.0);
                            } else {
                              controller.changeVolume(-10.0);
                            }
                          }
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Video(controller: controller.videoController),
                            ),
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
                            VolumeIndicator(controller: controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                  CourseStudyControlsBar(controller: controller),
                ],
              ),
            ),
            
            // Línea divisoria
            Container(width: 1, color: Colors.grey.shade800),
            
            //: PANEL DERECHO: ÍNDICE DE LECCIONES (Fijo)
            Expanded(
              flex: 3,
              child: RightPanelForLessonsAndResources(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}