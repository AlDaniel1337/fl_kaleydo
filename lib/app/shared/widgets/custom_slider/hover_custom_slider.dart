// lib/app/modules/media_player/views/widgets/hover_custom_slider.dart

import 'package:flutter/material.dart';
import 'custom_slider.dart';

enum ExpansionDirection { left, right, up, down }

/// Widget contenedor que despliega un slider animado al pasar el cursor (hover) o arrastrar.
class HoverCustomSlider extends StatefulWidget {
  
  //+ VARIABLES
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
  //!+

  @override
  State<HoverCustomSlider> createState() => _HoverCustomSliderState();
}

class _HoverCustomSliderState extends State<HoverCustomSlider> {
  //+ VARIABLES DE ESTADO
  bool _isHovered = false;
  bool _isDragging = false;

  bool get _shouldExpand => _isHovered || _isDragging;

  bool get _isVertical =>
      widget.expansionDirection == ExpansionDirection.up ||
      widget.expansionDirection == ExpansionDirection.down;
  //!+



  //+ ESTRUCTURA UI
  @override
  Widget build(BuildContext context) {
    final double targetWidth =
        _isVertical ? 36.0 : (_shouldExpand ? widget.expandedWidth + 36 : 36.0);
    final double targetHeight =
        _isVertical ? (_shouldExpand ? widget.expandedWidth + 36 : 36.0) : 36.0;

    final iconButton = IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      icon: Icon(widget.icon, color: Colors.white70, size: 18),
      onPressed: widget.onIconTap,
    );

    final sliderWidget = _AnimatedSliderContainer(
      isVertical: _isVertical,
      shouldExpand: _shouldExpand,
      expandedWidth: widget.expandedWidth,
      child: CustomSlider(
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
      ),
    );

    final List<Widget> children = _buildChildrenByDirection(
      iconButton: iconButton,
      sliderWidget: sliderWidget,
    );

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
          color: _shouldExpand
              ? Colors.black.withValues(alpha: 0.4)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: _isVertical
            ? Column(mainAxisSize: MainAxisSize.min, children: children)
            : Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
  //!+



  //+ MÉTODOS AUXILIARES
  /// Devuelve la lista de widgets en el orden correcto según la dirección de expansión.
  List<Widget> _buildChildrenByDirection({
    required Widget iconButton,
    required Widget sliderWidget,
  }) {
    switch (widget.expansionDirection) {
      case ExpansionDirection.right:
      case ExpansionDirection.down:
        return [iconButton, sliderWidget];
      case ExpansionDirection.left:
      case ExpansionDirection.up:
        return [sliderWidget, iconButton];
    }
  }
  //!+
}



//+ WIDGETS PRIVADOS
/// Helper Widget privado para contener la animación del slider desplegable.
class _AnimatedSliderContainer extends StatelessWidget {
  final bool isVertical;
  final bool shouldExpand;
  final double expandedWidth;
  final Widget child;

  const _AnimatedSliderContainer({
    required this.isVertical,
    required this.shouldExpand,
    required this.expandedWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isVertical ? 36 : (shouldExpand ? expandedWidth : 0),
      height: isVertical ? (shouldExpand ? expandedWidth : 0) : 36,
      child: ClipRect(
        child: SingleChildScrollView(
          scrollDirection: isVertical ? Axis.vertical : Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: isVertical ? 36 : expandedWidth,
            height: isVertical ? expandedWidth : 36,
            child: isVertical
                ? RotatedBox(quarterTurns: 3, child: child)
                : child,
          ),
        ),
      ),
    );
  }
}
//!+