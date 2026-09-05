import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/views/widgets/paginator/components/paginator_page_button.dart';

class CustomPaginador extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const CustomPaginador({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Indicador "X de Y"
        _buildBadge('$currentPage de $totalPages'),
        const SizedBox(width: 8),

        // Flecha izquierda (solo si no es la página 1)
        if (currentPage > 1)
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
            onPressed: () => onPageChanged(currentPage - 1),
          ),

        // Bloque dinámico de números
        ..._buildPageNumbers(),

        // Flecha derecha (solo si no es la última página)
        if (currentPage < totalPages)
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onPressed: () => onPageChanged(currentPage + 1),
          ),
      ],
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> items = [];

    // Si hay 5 o menos páginas, se muestran todas directamente
    if (totalPages <= 5) {
      for (int i = 1; i <= totalPages; i++) {
        items.add(_buildPageButton(i));
      }
      return items;
    }

    // Calculamos el rango de 3 páginas activas alrededor de la actual
    int start = currentPage - 1;
    int end = currentPage + 1;

    // Ajuste en el extremo inicial (ej: si estás en la pag 1 o 2) -> muestra 1, 2, 3
    if (currentPage <= 2) {
      start = 1;
      end = 3;
    } 
    // Ajuste en el extremo final (ej: si estás en la última o penúltima) -> muestra N-2, N-1, N
    else if (currentPage >= totalPages - 1) {
      start = totalPages - 2;
      end = totalPages;
    }

    // 1. Mostrar primera página + '...' si el bloque empieza más adelante de la página 2
    if (start > 1) {
      items.add(_buildPageButton(1));
      if (start > 2) {
        items.add(_buildEllipsis());
      }
    }

    // 2. Bloque de 3 páginas donde te encuentras
    for (int i = start; i <= end; i++) {
      items.add(_buildPageButton(i));
    }

    // 3. Mostrar '...' + última página si el bloque termina antes de la penúltima página
    if (end < totalPages) {
      if (end < totalPages - 1) {
        items.add(_buildEllipsis());
      }
      items.add(_buildPageButton(totalPages));
    }

    return items;
  }

  Widget _buildPageButton(int page) {
    return PaginatorPageButton(
      page: page,
      isSelected: page == currentPage,
      onTap: () => onPageChanged(page),
    );
  }

  Widget _buildEllipsis() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        '...',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}