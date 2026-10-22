import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';


/// Widget que muestra un botón para cambiar la velocidad de reproducción del video.
class ChangeVideoSpeedBtn extends StatelessWidget {
  const ChangeVideoSpeedBtn({
    super.key,
    required this.controller,
  });

  final CoursePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSpeed = controller.video.playbackSpeed.value;

      return PopupMenuButton<double>(
        initialValue: currentSpeed,
        tooltip: 'Velocidad de reproducción',
        color: AppColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onSelected: (double speed) => controller.video.setSpeed(speed),
        itemBuilder: (BuildContext context) {
          final speeds = [0.1, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.2];
          List<PopupMenuEntry<double>> menuItems = [];

          // Agrupamos las velocidades de 2 en 2
          for (int i = 0; i < speeds.length; i += 2) {
            final speed1 = speeds[i];
            final speed2 = i + 1 < speeds.length ? speeds[i + 1] : null;

            menuItems.add(
              PopupMenuItem<double>(
                enabled: false, // Deshabilitamos el tap global de la fila
                padding: EdgeInsets.zero,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSpeedOption(context, speed1, currentSpeed),
                    ),
                    if (speed2 != null)
                      Expanded(
                        child: _buildSpeedOption(context, speed2, currentSpeed),
                      )
                    else
                      // Espacio vacío para la última fila impar
                      const Expanded(child: SizedBox()), 
                  ],
                ),
              ),
            );
          }
          return menuItems;
        },
        
        /// Botón visible en la barra del reproductor
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon( Icons.speed_rounded,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text( '${currentSpeed}x',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 2),
              const Icon( Icons.arrow_drop_down_rounded,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
        ),
      );
    });
  }


  /// Construye el botón individual de velocidad dentro del menú emergente.
  Widget _buildSpeedOption(BuildContext context, double speed, double currentSpeed) {
    final isSelected = speed == currentSpeed;
    
    return InkWell(
      onTap: () {
        // Cierra el menú y envía el valor al 'onSelected' del PopupMenuButton
        Navigator.of(context).pop(speed); 
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${speed}x',
              style: TextStyle(
                color: isSelected ? AppColors.primaryAccent : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              const Icon( Icons.check_rounded,
                color: AppColors.primaryAccent,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}