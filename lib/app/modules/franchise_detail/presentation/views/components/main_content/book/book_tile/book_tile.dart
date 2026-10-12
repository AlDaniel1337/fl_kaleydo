import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';

class BookTile extends StatelessWidget {

  final FranchiseItemModel item;
  final bool isBook;
  final VoidCallback onTap;

  const BookTile({
    super.key,
    required this.item,
    required this.isBook,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {

    String subtitle = "Novela Ligera / Libro";

    if(!isBook){
      subtitle = (item.pagePaths.isNotEmpty && item.pagePaths.first.endsWith('.pdf')) 
        ? 'Documento PDF' 
        : '${item.pagePaths.length} Páginas';
    }

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isBook ? Icons.chrome_reader_mode_rounded : Icons.menu_book_rounded,
          color: AppColors.primaryAccent,
        ),
        title: Text(item.title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text( subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }
}