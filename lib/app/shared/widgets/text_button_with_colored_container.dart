import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class TextButtonWithColoredContainer extends StatelessWidget {

  final bool isSelected;
  final VoidCallback? onTap;
  final String text;
  final Color selectedColor; 
  final Color unselectedColor; 
   
  const TextButtonWithColoredContainer({
    super.key,
    required this.isSelected,
    required this.text,
    this.onTap,
    this.selectedColor = AppColors.primaryAccent,
    this.unselectedColor = Colors.white12,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedColor,
            borderRadius: BorderRadius.circular(6),
          ),
          
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected 
                ? FontWeight.bold 
                : FontWeight.normal,
              fontSize: 12,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),

        ),
      ),
    );
  }
}