import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Muestra un diálogo con la estructura de carpetas esperada para los cursos.
void showFolderStructureDialog(BuildContext context) {

  const String title = 'Estructura de Carpetas';

  const String content = 
  'Para que el escáner detecte correctamente tus cursos,\n' 
  'organiza tus archivos en 4 niveles:\n';
  
  const String levels = 
    '1. Carpeta raíz de cursos\n'
    '2. Categoría\n'
    '3. Curso\n'
    '4. Sección\n';

  const String extraInfo = 
  '• Los archivos que no sean imágenes o videos (PDFs, ZIPs)\n' 
  'se detectarán automáticamente como "Recursos" de la lección.';

  const String folderStructure = 
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
      '      └── ...'; 

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.cardBackground,

        title: const Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary, 
            fontWeight: FontWeight.bold
          ),
        ),

        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                content,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    levels,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: const Text( folderStructure,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Courier', // Fuente monoespaciada para alinear el árbol
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text( extraInfo,
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