import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/game_cover_image.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

class GameCard extends StatefulWidget {
  final FranchiseItemModel game;
  final bool isNovel;
  final VoidCallback? onExecute;
  final VoidCallback? onShowCGsGallery;
  final VoidCallback? onShowGuide;

  const GameCard({
    super.key,
    required this.game,
    required this.isNovel,
    this.onExecute,
    this.onShowCGsGallery,
    this.onShowGuide,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    const double cardBorderRadius = 18.0;
    const double innerImageBorderRadius = 12.0;

    final Color glowColor = AppColors.secondaryAccent.withValues(alpha: 0.6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(cardBorderRadius),
          border: Border.all(
            color: _isHovering ? glowColor : AppColors.cardBorder,
            width: _isHovering ? 2.5 : 1.0,
          ),
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

            //: Imagen de portada del juego
            Positioned.fill(
              child: GameCoverImage(
                coverPath: widget.game.coverPath,
                innerImageBorderRadius: innerImageBorderRadius,
              ),
            ),

            //: Jugar / Cancelar
            Positioned(
              bottom: 10, right: 15, left:  15,
              child: SizedBox(
                width: 200,
                height: 50,
                child: CountdownButton(
                  onExecute: widget.onExecute,
                  countdownDurationSeconds: 3,
                  showCancelButton: true,
                ),
              ),
            ),
            
            //: Galería CGS
            if (widget.onShowCGsGallery != null)
            Positioned(
              top: 10,
              right: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5), // O Colors.grey.withOpacity(0.4)
                  shape: BoxShape.circle, // Forma circular para adaptarse al IconButton
                ),
                child: IconButton(
                  icon: const Icon(Icons.photo_library),
                  color: AppColors.primaryAccent,
                  onPressed: widget.onShowCGsGallery,
                  tooltip: 'Ver Galería CGs',
                ),
              ),
            ),

            //: Guía
            if (widget.onShowGuide != null)
            Positioned(
              top: 60,
              right: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5), // O Colors.grey.withOpacity(0.4)
                  shape: BoxShape.circle, // Forma circular para adaptarse al IconButton
                ),
                child: IconButton(
                  icon: const Icon(Icons.menu_book),
                  color: AppColors.primaryAccent,
                  onPressed: widget.onShowGuide,
                  tooltip: 'Ver Guía',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}