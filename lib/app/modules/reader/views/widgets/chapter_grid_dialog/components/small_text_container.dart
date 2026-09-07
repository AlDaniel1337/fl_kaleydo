import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class SmallTextContainer extends StatelessWidget {
  const SmallTextContainer({
    super.key,
    required this.pageNum,
    required this.isCurrent,
  });

  final int pageNum;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$pageNum',
        style: TextStyle(
          color: isCurrent ? AppColors.primaryAccent : Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}