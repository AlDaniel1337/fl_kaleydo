import 'package:flutter/material.dart';

enum ExpansionDirection { left, right, up, down }

class HoverCustomSlider extends StatefulWidget {
  final IconData icon;
  final Color mainColor;
  final Color backgroundColor;
  final double sliderValue;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String? label;
  final int? divisions;
  final double expandedWidth;
  final VoidCallback? onIconTap;
  final ExpansionDirection expansionDirection;

  const HoverCustomSlider({
    super.key,
    required this.icon,
    required this.mainColor,
    required this.sliderValue,
    required this.onChanged,
    this.min = 0.1,
    this.max = 1.0,
    this.label,
    this.divisions,
    this.expandedWidth = 140.0,
    this.onIconTap,
    this.expansionDirection = ExpansionDirection.right,
    this.backgroundColor = Colors.white12,
  });

  @override
  State<HoverCustomSlider> createState() => _HoverCustomSliderState();
}

class _HoverCustomSliderState extends State<HoverCustomSlider> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isDragging = false;

  bool get _shouldExpand => _isHovered || _isDragging;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    final isVertical = widget.expansionDirection == ExpansionDirection.up ||
        widget.expansionDirection == ExpansionDirection.down;

    final double targetWidth = isVertical ? 36.0 : (_shouldExpand ? widget.expandedWidth + 36 : 36.0);
    final double targetHeight = isVertical ? (_shouldExpand ? widget.expandedWidth + 36 : 36.0) : 36.0;

    final iconButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(widget.icon, color: Colors.white70, size: 18),
      onPressed: widget.onIconTap,
    );

    final sliderWidget = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isVertical ? 36 : (_shouldExpand ? widget.expandedWidth : 0),
      height: isVertical ? (_shouldExpand ? widget.expandedWidth : 0) : 36,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: isVertical ? 36 : widget.expandedWidth,
            height: isVertical ? widget.expandedWidth : 36,
            child: isVertical
                ? RotatedBox(
                    quarterTurns: 3, // Rotación vertical para el Slider
                    child: _buildSlider(),
                  )
                : _buildSlider(),
          ),
        ),
      ),
    );

    List<Widget> children;
    switch (widget.expansionDirection) {
      case ExpansionDirection.right:
        children = [iconButton, sliderWidget];
        break;
      case ExpansionDirection.left:
        children = [sliderWidget, iconButton];
        break;
      case ExpansionDirection.down:
        children = [iconButton, sliderWidget];
        break;
      case ExpansionDirection.up:
        children = [sliderWidget, iconButton];
        break;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: targetWidth,
        height: targetHeight,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: _shouldExpand ? Colors.black.withValues(alpha: 0.4) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: isVertical
            ? Column(mainAxisSize: MainAxisSize.min, children: children)
            : Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildSlider() {
    return CustomSlider(
      mainColor: widget.mainColor,
      backgroundColor: widget.backgroundColor,
      sliderValue: widget.sliderValue,
      onChanged: widget.onChanged,
      onChangeStart: (_) => setState(() => _isDragging = true),
      onChangeEnd: (_) => setState(() => _isDragging = false),
      min: widget.min,
      max: widget.max,
      label: widget.label,
      divisions: widget.divisions,
    );
  }
}

class CustomSlider extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    Color valueIndicatorColor = mainColor == Colors.white
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
        divisions: divisions ?? ((max - min) ~/ 0.1),
        label: label,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

class CustomPillThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const CustomPillThumbShape({this.width = 6, this.height = 16});

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

    final rect = Rect.fromCenter(center: center, width: width, height: height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(rrect, paint);
  }
}