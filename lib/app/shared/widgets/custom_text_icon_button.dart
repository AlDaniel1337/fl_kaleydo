import 'package:flutter/material.dart';

enum IconPosition { left, right }

class CustomTextIconButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final IconPosition iconPosition;
  final MouseCursor enabledCursor;
  final MouseCursor disabledCursor;
  final Color hoverColor;
  final Color splashColor;
  final double hoverScale; 
  const CustomTextIconButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.isEnabled = true,
    this.iconPosition = IconPosition.right,
    this.enabledCursor = SystemMouseCursors.click,
    this.disabledCursor = SystemMouseCursors.forbidden,
    this.hoverColor = Colors.white10,
    this.splashColor = Colors.white12,
    this.hoverScale = 1.05,
  });

  @override
  State<CustomTextIconButton> createState() => _CustomTextIconButtonState();
}

class _CustomTextIconButtonState extends State<CustomTextIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isEnabled ? Colors.white : Colors.white24;

    final children = [
      Text(
        widget.label,
        style: TextStyle(color: color),
      ),
      const SizedBox(width: 4),
      Icon(
        widget.icon,
        color: color,
      ),
    ];

    return MouseRegion(
      cursor: widget.isEnabled ? widget.enabledCursor : widget.disabledCursor,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: (widget.isEnabled && _isHovered) ? widget.hoverScale : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: (widget.isEnabled && _isHovered)
                ? widget.hoverColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: InkWell(
            onTap: widget.isEnabled ? widget.onPressed : null,
            borderRadius: BorderRadius.circular(6),
            splashColor: widget.splashColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: widget.iconPosition == IconPosition.left
                    ? children.reversed.toList()
                    : children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}