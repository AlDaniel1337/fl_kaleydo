import 'package:flutter/material.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/book/book_grid_item/book_grid_item.dart';

class BookGridView extends StatelessWidget {

  final List<FranchiseItemModel> items;
  final Function(int) onTap;
   
  const BookGridView({
    super.key, 
    required this.items,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6, //  columnas de capítulos
        childAspectRatio: 0.7, // Proporción vertical típica de manga
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),

      itemCount: items.length,
      itemBuilder: (ctx, idx) {
        
        // Obtenemos la primera imagen del capítulo para usarla como miniatura
        final chapter = items[idx];
        final String? firstImage = chapter.pagePaths.isNotEmpty 
          ? chapter.pagePaths.first 
          : null;

        return BookGridItem(
          items: items, 
          firstImage: firstImage, 
          chapter: chapter,
          idx: idx,
        );
      },
    );
  }
}