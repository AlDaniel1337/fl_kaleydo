import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class CustomNavItem extends StatelessWidget {

  final IconData icon;
  final String label;
  final String rawCategory;
  final bool isUnknown;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.rawCategory,
    this.isUnknown = false,
    this.isSelected = false,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF232038) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [

                //: Icono
                Icon( icon,
                  size: 18,
                  color: isSelected
                    ? AppColors.primaryAccent
                    : (isUnknown ? Colors.amber : AppColors.textSecondary),
                ),
                const SizedBox(width: 14),

                //: Texto del elemento de navegación
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      )
    );
  }
}