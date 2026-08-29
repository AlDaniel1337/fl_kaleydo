import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';

/// Badge que muestra el tipo de contenido de un elemento multimedia.
class ContentTypeBadge extends StatelessWidget {
   
  final MediaItemModel item;

  const ContentTypeBadge({
    super.key, 
    required this.item
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.background.withAlpha(210),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Icon(
        item.type.icon,
        size: 14,
        color: AppColors.primaryAccent,
      ),
    );
  }
}