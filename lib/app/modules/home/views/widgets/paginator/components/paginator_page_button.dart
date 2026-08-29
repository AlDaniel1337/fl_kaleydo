import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Botón de página del paginador.
/// 
/// Muestra un número de página y cambia su apariencia si está seleccionado.
class PaginatorPageButton extends StatelessWidget {

  final void Function() onTap;
  final int page;
  final bool isSelected;
   
  const PaginatorPageButton({
    super.key,
    required this.onTap,
    required this.page,
    required this.isSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : Colors.transparent,
            shape: BoxShape.circle,
          ),

          // Número de página dentro del botón
          child: Text(
            '$page',
            style: TextStyle(
              color: isSelected 
                ? Colors.white 
                : AppColors.textSecondary,
              fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
              fontSize: 13,
            ),

          ),
        ),
      ),
    );
  }
}