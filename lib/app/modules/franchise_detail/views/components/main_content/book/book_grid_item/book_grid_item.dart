import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/reader/views/reader_view.dart';

class BookGridItem extends StatelessWidget {
  const BookGridItem({
    super.key,
    required this.items,
    required this.chapter,
    required this.idx,
    this.firstImage,
  });

  final List<FranchiseItemModel> items;
  final String? firstImage;
  final FranchiseItemModel chapter;
  final int idx;

  @override
  Widget build(BuildContext context) {
    return InkWell(
    
      onTap: () {
        Get.toNamed(
          ReaderView.route,
          arguments: {
            'chapterList': items,
            'currentIndex': idx,
          },
        );
      },
    
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            //: Imagen de la primera página como miniatura
            Expanded(
              child: firstImage != null
                ? Image.file(
                  File(firstImage!),
                  fit: BoxFit.cover,
                  cacheWidth: 300,
                )
                : Container(
                  color: Colors.black26,
                  child: const Icon(Icons.broken_image_rounded, color: Colors.white54),
                ),
            ),
    
            //: Título del capítulo
            Container(
              padding: const EdgeInsets.all(8),
              color: AppColors.cardBackground,
              child: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    
          ],
        ),
      ),
    );
  }
}