import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class BookSubHeader extends StatelessWidget {

  final bool isMangaGridView;
  final VoidCallback onToggleView;
  final Widget? pageSelector;
   
  const BookSubHeader({
    super.key, 
    required this.isMangaGridView, 
    required this.onToggleView,
    this.pageSelector,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ToggleButtons(
            isSelected: [!isMangaGridView, isMangaGridView],
            onPressed: (_) => onToggleView(),
            color: AppColors.textSecondary,
            selectedColor: Colors.white,
            fillColor: AppColors.primaryAccent.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
            children: const [
              Tooltip(message: 'Vista de lista', child: Icon(Icons.list_rounded, size: 18)),
              Tooltip(message: 'Vista de cuadrícula', child: Icon(Icons.grid_view_rounded, size: 18)),
            ],
          ),

          ?pageSelector,
          
        ],
      ),
    );
  }
}