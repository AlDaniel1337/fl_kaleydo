import 'package:flutter/material.dart';

class HoverZoom extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;

  const HoverZoom({
    super.key,
    required this.child,
    this.scale = 1.08, // Factor de ampliación (8% más grande)
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<HoverZoom> createState() => _HoverZoomState();
}

class _HoverZoomState extends State<HoverZoom> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}