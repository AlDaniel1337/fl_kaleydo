import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kaleydo/app/config/theme/app_colors.dart';


class CourseCard extends StatelessWidget {

  final String title;
  final String subtitle;
  final String coverPath;
  final VoidCallback onTap;
  final double? progress;

  const CourseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverPath,
    required this.onTap,
    this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(

        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),

        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            //: Portada (Cover)
            Expanded(
              child: coverPath.isNotEmpty && File(coverPath).existsSync()
                ? Image.file(
                    File(coverPath),
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  )
                : Container(
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.school, size: 64, color: Colors.white24),
                  ),
            ),

            //: Barra de progreso (Solo se muestra en los Cursos)
            if (progress != null)
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade800,
                color: AppColors.primaryAccent,
                minHeight: 4,
              ),
            
            //: Textos
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}