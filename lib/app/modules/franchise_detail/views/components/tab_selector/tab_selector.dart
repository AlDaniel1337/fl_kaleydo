import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';

/// Widget para seleccionar la pestaña de un medio de franquicia.
class TabSelector extends StatelessWidget {

  final List<FranchiseMediaType> availableTabs;
  final FranchiseMediaType selectedTab;
  final ValueChanged<FranchiseMediaType> onTabSelected;
   
  const TabSelector({
    super.key,
    required this.availableTabs,
    required this.selectedTab,
    required this.onTabSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        children: availableTabs.map((tab) {

          final isSelected = selectedTab == tab;

          return ChoiceChip(
            label: Text(_getTabName(tab)),
            selected: isSelected,
            selectedColor: AppColors.primaryAccent,
            backgroundColor: AppColors.cardBackground,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) {
              onTabSelected(tab);
            },
          );
          
        }).toList(),
      ),
    );
  }


  //: Nombre de las pestañas
  /// Obtiene el nombre legible de una pestaña según su tipo de medio de franquicia.
  String _getTabName(FranchiseMediaType type) {
    switch (type) {
      case FranchiseMediaType.juegos:  return 'Juegos';
      case FranchiseMediaType.manga:   return 'Manga';
      case FranchiseMediaType.manhwa:  return 'Manhwa';
      case FranchiseMediaType.anime:   return 'Anime';
      case FranchiseMediaType.videos:  return 'Videos';
      case FranchiseMediaType.resumen: return 'Resumen';
      case FranchiseMediaType.libros:  return 'Libros';
      case FranchiseMediaType.novelas: return 'Novelas Visuales';
    }
  }
}
