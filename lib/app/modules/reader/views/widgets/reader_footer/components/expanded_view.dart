import 'package:flutter/material.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

class ExpandedView extends StatelessWidget {

  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;
  final String? currentPageIndicator;
  final VoidCallback? onScrollToTop;
   
  const ExpandedView({
    super.key,
    this.onPreviousChapter,
    this.onNextChapter,
    this.currentPageIndicator,
    this.onScrollToTop,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //: Botón de capítulo anterior
        CustomTextIconButton(
          label: 'Cap. anterior',
          icon: Icons.chevron_left,
          onPressed: onPreviousChapter,
          isEnabled: onPreviousChapter != null,
          iconPosition: IconPosition.left,
          enabledCursor: SystemMouseCursors.click,
          disabledCursor: SystemMouseCursors.forbidden,
        ),
        const Spacer(),

        //: Indicador de página actual
        Text(
          currentPageIndicator ?? '0 / 0',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),

        // Botón de ir al comienzo
        IconButton(
          icon: const Icon(
            Icons.arrow_upward_rounded,
            color: Colors.white,
          ),
          tooltip: 'Ir al comienzo',
          onPressed: onScrollToTop,
        ),
        const Spacer(),

        //: Botón de capítulo siguiente
        CustomTextIconButton(
          label: 'Cap. siguiente',
          icon: Icons.chevron_right,
          onPressed: onNextChapter,
          isEnabled: onNextChapter != null,
          enabledCursor: SystemMouseCursors.click,
          disabledCursor: SystemMouseCursors.forbidden,
        ),
      ],
    );
  } 
}