import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Widget que representa la barra de búsqueda global en el encabezado de la aplicación.
class GlobalSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const GlobalSearchBar({super.key, required this.onChanged});

  @override
  State<GlobalSearchBar> createState() => _GlobalSearchBarState();
}

class _GlobalSearchBarState extends State<GlobalSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberar memoria cuando el widget se destruye
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
  }

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
          controller: _controller,
          onChanged: widget.onChanged,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            height: 1.0,
          ),
          decoration: decoration(),
        ),
      ),
    );
  }



  /// Devuelve la decoración del campo de búsqueda.
  InputDecoration decoration() {

    double minWidth = 36.0;
    double maxHeight = 38.0;
    double iconSize = 18.0;

    return InputDecoration(
      isCollapsed: true,
      hintText: 'Buscar...',
      border: InputBorder.none,
      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        height: 1.0,
      ),
      prefixIcon: Icon(Icons.search, size: iconSize, color: AppColors.textSecondary),
      prefixIconConstraints: BoxConstraints(
        minWidth: minWidth,
        maxHeight: maxHeight,
      ),
      suffixIcon: IconButton(
        onPressed: _clearSearch,
        icon: Icon(Icons.clear, size: iconSize, color: AppColors.textSecondary),
      ),
      suffixIconConstraints: BoxConstraints(
        minWidth: minWidth,
        maxHeight: maxHeight,
      ),
    );
  }
}