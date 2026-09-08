// lib/app/modules/media_player/views/widgets/custom_slider.dart

import 'package:flutter/material.dart';
import 'custom_pill_thumb_shape.dart';

/// Slider estilizado reutilizable con un thumb en forma de cápsula (Pill Shape).
class CustomSlider extends StatelessWidget {
  
  //+ VARIABLES
  final Color mainColor;
  final Color backgroundColor;
  final double sliderValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final String? label;
  final int? divisions;

  const CustomSlider({
    super.key,
    required this.mainColor,
    required this.sliderValue,
    required this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.1,
    this.max = 1.0,
    this.label,
    this.divisions,
    this.backgroundColor = Colors.white12,
  });
  //!+


  //+ ESTRUCTURA UI
  @override
  Widget build(BuildContext context) {
    final Color valueIndicatorColor = mainColor == Colors.white
        ? Colors.black38
        : mainColor.withValues(alpha: 0.38);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.0,
        activeTrackColor: mainColor,
        inactiveTrackColor: backgroundColor,
        thumbColor: mainColor,
        overlayColor: mainColor.withValues(alpha: 0.2),
        thumbShape: const CustomPillThumbShape(width: 4, height: 12),
        tickMarkShape: SliderTickMarkShape.noTickMark,
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        valueIndicatorColor: valueIndicatorColor,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
      ),
      child: Slider(
        value: sliderValue.clamp(min, max),
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
  //!+
}