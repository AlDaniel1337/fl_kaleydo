import 'dart:async';
import 'package:flutter/material.dart';

class QuickAndLongPressIconButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final IconData icon;
  final String tooltip;
  final Color activeColor;
  final Color inactiveColor;
  final Duration longPressDuration;

  const QuickAndLongPressIconButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.onLongPress,
    required this.icon,
    this.tooltip = '',
    this.activeColor   = Colors.blue,
    this.inactiveColor = Colors.white,
    this.longPressDuration = const Duration(milliseconds: 300),
  });

  @override
  State<QuickAndLongPressIconButton> createState() => _QuickAndLongPressIconButtonState();
}

class _QuickAndLongPressIconButtonState extends State<QuickAndLongPressIconButton> {
  
  Timer? _longPressTimer;
  bool _isLongPressTriggered = false;

  /// Inicia el temporizador para detectar una pulsación larga y ejecutar la acción correspondiente.
  void _startTimer() {
    _isLongPressTriggered = false;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(widget.longPressDuration, () {
      _isLongPressTriggered = true;
      widget.onLongPress();
    });
  }



  /// Cancela el temporizador y ejecuta la acción simple
  void _cancelTimerAndExecuteTap() {
    if (_longPressTimer?.isActive ?? false) {
      _longPressTimer?.cancel();
      if (!_isLongPressTriggered) {
        widget.onTap();
      }
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Listener(
        onPointerDown:   (_) => _startTimer(),
        onPointerUp:     (_) => _cancelTimerAndExecuteTap(),
        onPointerCancel: (_) => _longPressTimer?.cancel(),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {}, // Necesario para mantener la animación visual (ripple)
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              widget.icon,
              color: widget.isActive ? widget.activeColor : widget.inactiveColor,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}