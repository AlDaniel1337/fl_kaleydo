import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Widget para seleccionar la temporada de un anime.
class SeasonSelector extends StatelessWidget {

  final List<String> animeSeasons;
  final String selectedAnimeSeason;
  final Function(String) changeAnimeSeason;
   
  const SeasonSelector({
    super.key,
    required this.animeSeasons,
    required this.selectedAnimeSeason,
    required this.changeAnimeSeason,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Row(
        children: animeSeasons.map((season) {
          
          final isSelected = selectedAnimeSeason == season;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(season),
              selected: isSelected,
              selectedColor: const Color(0xFF2B2845),
              backgroundColor: AppColors.sidebarBackground,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
                fontSize: 12,
              ),
              onSelected: (_) => changeAnimeSeason(season),
            ),
          );
        }).toList(),
      ),
    );
  }
}