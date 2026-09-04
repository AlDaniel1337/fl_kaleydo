import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

enum IconPosition { left, right }

class EpisodeCardWidget extends StatelessWidget {
  final String label;
  final String title;
  final IconData icon;
  final VoidCallback onPressed;
  final IconPosition iconPosition;

  const EpisodeCardWidget({
    super.key,
    required this.label,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.iconPosition = IconPosition.left,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = iconPosition == IconPosition.left;

    final iconWidget = Icon(
      icon,
      color: AppColors.primaryAccent,
      size: 24,
    );

    final textWidget = Column(
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white54,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );

    final children = [
      iconWidget,
      const SizedBox(width: 8),
      Expanded(child: textWidget),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: isLeft ? children : children.reversed.toList(),
          ),
        ),
      ),
    );
  }
}