import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


//TODO: Implement the quick filter dropdown functionality.
class QuickFilterDropdown extends StatelessWidget {
   
  const QuickFilterDropdown({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: const [
          Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Text(
            'Filter by name...',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}