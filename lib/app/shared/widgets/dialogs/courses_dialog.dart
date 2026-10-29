import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Muestra un diálogo que explica la estructura de carpetas requerida para los [CURSOS].
void showFolderStructureDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Estructura de Carpetas',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para que el escáner detecte correctamente tus cursos, organiza tus archivos en 4 niveles:\n',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: const Text(
                  '📁 cursos/ (Carpeta Raíz)\n'
                  ' ├── 📁 Categoría (Ej. Flutter)\n'
                  ' │    ├── 🖼️ cover.jpg (Opcional)\n'
                  ' │    └── 📁 Curso (Ej. Curso Dart)\n'
                  ' │         ├── 🖼️ cover.jpg (Opcional)\n'
                  ' │         ├── 📁 01 - Intro (Sección)\n'
                  ' │         │    ├── 🎬 01-Video.mp4\n'
                  ' │         │    └── 📄 cheat_sheet.pdf\n'
                  ' │         └── 📁 02 - Avanzado\n'
                  ' │              └── 🎬 02-Video.mp4\n'
                  ' └── 📁 Blender\n'
                  '      └── ...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Courier', // Fuente monoespaciada para alinear el árbol
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '• Los archivos que no sean imágenes o videos (PDFs, ZIPs) se detectarán automáticamente como "Recursos" de la lección.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(color: AppColors.primaryAccent),
            ),
          ),
        ],
      );
    },
  );
}