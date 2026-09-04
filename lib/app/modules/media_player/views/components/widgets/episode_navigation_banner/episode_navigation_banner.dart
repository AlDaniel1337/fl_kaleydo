import 'package:flutter/material.dart';
import 'package:kaleydo/app/modules/media_player/views/components/widgets/episode_card_widget/episode_card_widget.dart';

/// Widget que muestra un banner de navegación para episodios, ya sea el siguiente o el previo.
class EpisodeNavigationBanner extends StatelessWidget {
  final bool isNext;
  final bool isVisible;
  final String episodeTitle;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;

  const EpisodeNavigationBanner({
    super.key,
    required this.isNext,
    required this.isVisible,
    required this.episodeTitle,
    required this.onTap,
    required this.onHoverChanged,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = isNext ? Alignment.bottomRight : Alignment.bottomLeft;
    final padding = isNext 
        ? const EdgeInsets.only(right: 24, bottom: 10)
        : const EdgeInsets.only(left: 24, bottom: 10);

    return Positioned(
      left: isNext ? null : 0,
      right: isNext ? 0 : null,
      top: 60,
      bottom: 100,
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.translucent,
        onEnter: (_) => onHoverChanged(true),
        onExit: (_) => onHoverChanged(false),
        child: SizedBox(
          width: 250,
          child: IgnorePointer(
            ignoring: !isVisible,
            child: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Align(
                alignment: alignment,
                child: Padding(
                  padding: padding,
                  child: EpisodeCardWidget(
                    label: episodeTitle,
                    title: isNext ? 'Siguiente Episodio' : 'Episodio Previo',
                    icon: isNext ? Icons.skip_next_rounded : Icons.skip_previous_rounded,
                    onPressed: onTap,
                    iconPosition: isNext ? IconPosition.right : IconPosition.left,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}