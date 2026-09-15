import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class ResumeBanner extends StatelessWidget {

  final String title;
  final VoidCallback onResume;
   
  const ResumeBanner({
    super.key,
    required this.title,
    required this.onResume,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: AppColors.primaryAccent.withValues(alpha: 0.4),
        ),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Icon(
          Icons.play_circle_filled_rounded,
          color: AppColors.primaryAccent,
          size: 30,
        ),

        title: const Text('Continuar desde donde lo dejaste',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        subtitle: Text( title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 14),
          label: const Text('Continuar', style: TextStyle(fontSize: 12)),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            onResume();
          },
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onResume();
        },
      ),
    );
  }
}