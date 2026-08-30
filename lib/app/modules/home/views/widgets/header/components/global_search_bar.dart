import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Widget que representa la barra de búsqueda global en el encabezado de la aplicación.
class GlobalSearchBar extends StatelessWidget {

  final ValueChanged<String> onChanged;

  const GlobalSearchBar({super.key, required this.onChanged});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center( 
        child: TextField(
          onChanged: onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            color: AppColors.textPrimary, 
            fontSize: 13,
            height: 1.0, // Fuerza al texto a no tener espaciado vertical extra
          ),
          decoration: const InputDecoration(
            isCollapsed: true, // Elimina completamente el layout y paddings internos por defecto
            hintText: 'Buscar...',
            hintStyle: TextStyle(
              color: AppColors.textSecondary, 
              fontSize: 13,
              height: 1.0, // Mismo height que el texto principal
            ),
            prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textSecondary),
            prefixIconConstraints: BoxConstraints(
              minWidth: 36, // Define el ancho que ocupa el icono horizontalmente
              maxHeight: 38, // Evita que empuje la altura de 38px
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}