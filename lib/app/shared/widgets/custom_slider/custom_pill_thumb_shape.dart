// lib/app/modules/media_player/views/widgets/custom_pill_thumb_shape.dart

import 'package:flutter/material.dart';

/// Forma personalizada para el cursor del slider en forma de píldora vertical (Pill Shape).
class CustomPillThumbShape extends SliderComponentShape {
  
  //+ VARIABLES
  final double width;
  final double height;
  final double borderRadius;

  const CustomPillThumbShape({
    this.width = 6.0,
    this.height = 16.0,
    this.borderRadius = 4.0,
  });
  //!+



  //+ CONFIGURACIÓN Y DIBUJO
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(width, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    
    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );

    final effectiveRadius = Radius.circular(
      borderRadius.clamp(0.0, width / 2),
    );

    final rrect = RRect.fromRectAndRadius(rect, effectiveRadius);
    canvas.drawRRect(rrect, paint);
  }
  //!+
}