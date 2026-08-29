import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Widget que representa un botón de pestaña en el encabezado.
class TabButton extends StatelessWidget {

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text( label,
            style: TextStyle(
              color: isSelected 
                ? AppColors .textPrimary 
                : AppColors.textSecondary,
              fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 24,
              color: AppColors.primaryAccent,
            ),
        ],
      ),
    );
  }
}