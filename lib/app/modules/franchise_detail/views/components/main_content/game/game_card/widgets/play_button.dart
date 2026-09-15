// lib/app/global_widgets/play_button.dart

import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Botón interactivo de reproducción con soporte para estados de cuenta regresiva,
/// animaciones de transición y personalización de temas.
class PlayButton extends StatelessWidget {

  //+ VARIABLES
  final bool isCountingDown;
  final int countdownSeconds;
  final VoidCallback? onPlayOrCancel;

  static const double _borderRadiusValue = 20.0;
  static const BorderRadius _borderRadius =
      BorderRadius.all(Radius.circular(_borderRadiusValue));

  const PlayButton({
    super.key,
    required this.isCountingDown,
    required this.countdownSeconds,
    required this.onPlayOrCancel,
  });
  //!+



  //+ ESTRUCTURA UI
  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isCountingDown ? Colors.deepOrange : AppColors.primaryAccent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: _borderRadius,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlayOrCancel,
          borderRadius: _borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: _buildButtonContent(),
            ),
          ),
        ),
      ),
    );
  }
  //!+



  //+ MÉTODOS AUXILIARES
  /// Construye el contenido del botón según si la cuenta regresiva está activa.
  Widget _buildButtonContent() {
    return Row(
      key: ValueKey<bool>(isCountingDown),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCountingDown ? Icons.timer_outlined : Icons.play_arrow,
          size: 18,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          isCountingDown
              ? 'Lanzando en ${countdownSeconds}s'
              : 'Jugar',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
  //!+
}