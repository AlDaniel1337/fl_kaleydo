import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class ResumingIndicator extends StatelessWidget {
   
  const ResumingIndicator({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, 
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const CircularProgressIndicator(
              color: AppColors.primaryAccent,
              strokeWidth: 4,
            ),
            const SizedBox(height: 16),
            
            Text(
              'Reanudando última página',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

          ],
        ),
      ),
    );
  }
}