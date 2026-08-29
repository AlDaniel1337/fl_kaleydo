import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/views/widgets/paginator/components/paginator_page_button.dart';

/// Widget de paginación que muestra botones para navegar entre páginas.
class Paginador extends StatelessWidget {

  final int current;
  final int total;
  final void Function(int) onPageChanged;

  const Paginador({
    super.key,
    required this.current,
    required this.total,
    required this.onPageChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        // Botón de página anterior
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          onPressed: current > 1 ? () => onPageChanged(current - 1) : null,
        ),
        const SizedBox(width: 8),

        // Botones de páginas individuales
        for (int page = 1; page <= (total > 3 ? 3 : total); page++)
          PaginatorPageButton(
            page: page,
            isSelected: page == current,
            onTap: () => onPageChanged(page),
          ),

        // Botón de página siguiente si hay más de 3 páginas
        if (total > 3) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: Text('...', style: TextStyle(color: AppColors.textSecondary)),
          ),
          PaginatorPageButton(
            page: total,
            isSelected: total == current,
            onTap: () => onPageChanged(total),
          ),
        ],
        const SizedBox(width: 8),

        // Botón de página siguiente
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onPressed: current < total ? () => onPageChanged(current + 1) : null,
        ),
      ],
    );
  }
}