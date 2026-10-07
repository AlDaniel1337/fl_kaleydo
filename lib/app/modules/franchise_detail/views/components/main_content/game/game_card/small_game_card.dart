import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/game_cover_image.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/game_title.dart';

class SmallGameCard extends StatefulWidget {
  final FranchiseItemModel game;
  final bool isNovel;
  final void Function() onTap;
  final bool showButtons;

  const SmallGameCard({
    super.key,
    required this.game,
    required this.isNovel,
    required this.onTap,
    this.showButtons = true,
  });

  @override
  State<SmallGameCard> createState() => _SmallGameCardState();
}

class _SmallGameCardState extends State<SmallGameCard> {
  bool _isHovering = false;


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    // Bordes
    final double cardBorderRadius = 18.0;
    final double innerImageBorderRadius = 12.0;

    // Brillo
    final Color glowColor = AppColors.secondaryAccent.withValues(alpha: 0.6);


    return MouseRegion(

      //: Hover
      onEnter: (_) => setState(() => _isHovering = true),
      onExit:  (_) => setState(() => _isHovering = false),

      //: Contenedor animado del juego
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),

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
                    onPlayOrCancel: widget.onTap,
                  ),
                ),
                const SizedBox(height: 12),
            
                //: Título del juego
                GameSmallTitle(title: widget.game.title),
                const SizedBox(height: 12),
            
              ],
            ),

          ],
        ),
      ),
    );
  }
}