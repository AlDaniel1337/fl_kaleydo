import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'cover_placeholder.dart';



/// Widget que muestra la imagen de portada de un elemento de medios.
/// Si no hay una imagen disponible, se muestra un placeholder.
class CoverImage extends StatelessWidget {
   
  final MediaItemModel item;

  const CoverImage({
    super.key, 
    required this.item
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
        //: Imagen de portada del contenido
        Expanded(
          child: Container(
            width: double.infinity,
            color: const Color(0xFF201D33),
            child: item.coverPath != null
                ? Image.file(
                    File(item.coverPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => CoverPlaceholder(),
                  )
                : CoverPlaceholder(),
          ),
        ),
        
        //: Título inferior del contenido
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          color: AppColors.cardBackground,
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}