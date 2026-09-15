import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/cancel_button.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/game_cover_image.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/game_title.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/play_button.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/secondary_button.dart';

class GameCard extends StatefulWidget {
  final FranchiseItemModel game;
  final bool isNovel;
  final void Function(String executablePath) launchExecutable;

  const GameCard({
    super.key,
    required this.game,
    required this.isNovel,
    required this.launchExecutable,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isHovering = false;

  // Variables para la cuenta regresiva
  Timer? _timer;
  final int _originalCountdownSeconds = 3;
  int _countdownSeconds = 3;
  bool _isCountingDown = false;

  bool get showCgsButton   => _isCountingDown && widget.isNovel && widget.game.hasCgs;
  bool get showGuideButton => _isCountingDown && widget.isNovel && widget.game.hasGuide;

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  /// Inicia la cuenta regresiva para lanzar el ejecutable del juego.
  void _startCountdown() {
    
    // Validación de seguridad
    if (widget.game.executablePath == null) return; 

    setState(() {
      _isCountingDown = true;
      _countdownSeconds = _originalCountdownSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 1) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _cancelCountdown();
        widget.launchExecutable(widget.game.executablePath!);
      }
    });
  }


  /// Cancela la cuenta regresiva para lanzar el ejecutable del juego.
  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdownSeconds = _originalCountdownSeconds;
    });
  }


  /// Alterna la acción de reproducir o cancelar la cuenta regresiva del juego.
  void _togglePlayAction() {
    if (_isCountingDown) {
      _cancelCountdown();
    } else {
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {

    // Bordes
    final double cardBorderRadius = 18.0;
    final double innerImageBorderRadius = 12.0;

    // Brillo
    final Color glowColor = AppColors.secondaryAccent.withValues(alpha: 0.6);

    // Acción de clic para reproducir o cancelar el juego
    final VoidCallback? onPlayOrCancel = widget.game.executablePath != null
      ? _togglePlayAction
      : null;

    return MouseRegion(

      //: Hover
      onEnter: (_) => setState(() => _isHovering = true),
      onExit:  (_) => setState(() => _isHovering = false),

      //: Contenedor animado del juego
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),

        // Decoración del contenedor principal
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          border: Border.all(
            color: _isHovering ? glowColor : AppColors.cardBorder,
            width: _isHovering ? 2.5 : 1.0,
          ),

          // Efecto de sombra y brillo
          boxShadow: [
            BoxShadow(
              color: _isHovering
                  ? glowColor.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: _isHovering ? 15 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            
                //: Imagen de portada del juego
                Expanded(
                  child: GameCoverImage(
                    coverPath: widget.game.coverPath,
                    innerImageBorderRadius: innerImageBorderRadius,
                    onPlayOrCancel: onPlayOrCancel,
                  ),
                ),
                const SizedBox(height: 12),
            
                //: Título del juego
                GameTitle(title: widget.game.title),
                const SizedBox(height: 12),
            
                // Fila de botones
                Row(
                  children: [
                    //: Botón principal-  "Jugar / Cancelar" 
                    Expanded(
                      child: PlayButton(
                        isCountingDown: _isCountingDown,
                        countdownSeconds: _countdownSeconds,
                        onPlayOrCancel: onPlayOrCancel,
                      ),
                    ),
            
                    //: Botones secundarios
                    if (_isCountingDown) ...[
                      SizedBox(width: 8),
                      CancelButton(onCancelCountdown: _cancelCountdown),                
                    ],                    
                  ],
                )
              ],
            ),

            if (showCgsButton)
              Positioned(
                top: 0,
                right: 0,
                child: SecondaryButton(
                  label: 'CGs',
                  onPressed: () => print('CGs button pressed'),
                )
              ),
          
            if (showGuideButton)
              Positioned(
                top: showCgsButton ? 40 : 0,
                right: 0,
                child: SecondaryButton(
                  label: 'Guía',
                  onPressed: () => print('Guía button pressed'),
                ),
              ),

          ],
        ),
      ),
    );
  }
}