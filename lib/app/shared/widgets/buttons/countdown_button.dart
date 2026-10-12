import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/views/components/main_content/game/game_card/widgets/cancel_button.dart';

/// Botón ejecutor reutilizable con temporizador integrado.
class CountdownButton extends StatefulWidget {
  final VoidCallback? onExecute;
  final int countdownDurationSeconds;
  final bool showCancelButton;

  const CountdownButton({
    super.key,
    required this.onExecute,
    this.countdownDurationSeconds = 3,
    this.showCancelButton = true,
  });

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton> {
  Timer? _timer;
  late int _countdownSeconds;
  bool _isCountingDown = false;

  static const double _borderRadiusValue = 20.0;
  static const BorderRadius _borderRadius =
      BorderRadius.all(Radius.circular(_borderRadiusValue));

  @override
  void initState() {
    super.initState();
    _countdownSeconds = widget.countdownDurationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    if (widget.onExecute == null) return;

    setState(() {
      _isCountingDown = true;
      _countdownSeconds = widget.countdownDurationSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _cancelCountdown();
        widget.onExecute?.call();
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _isCountingDown = false;
        _countdownSeconds = widget.countdownDurationSeconds;
      });
    }
  }

  void _togglePlayAction() {
    if (_isCountingDown) {
      _cancelCountdown();
    } else {
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _isCountingDown 
    ? Colors.deepOrange 
    : AppColors.primaryAccent;

    final isEnabled = widget.onExecute != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isEnabled ? backgroundColor : Colors.grey,
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
                onTap: isEnabled ? _togglePlayAction : null,
                borderRadius: _borderRadius,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
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
          ),
        ),
        if (_isCountingDown && widget.showCancelButton) ...[
          const SizedBox(width: 8),
          CancelButton(onCancelCountdown: _cancelCountdown),
        ],
      ],
    );
  }

  Widget _buildButtonContent() {
    return Row(
      key: ValueKey<bool>(_isCountingDown),
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _isCountingDown ? Icons.timer_outlined : Icons.play_arrow,
          size: 18,
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Text(
          _isCountingDown ? 'Lanzando en ${_countdownSeconds}s' : 'Jugar',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}