import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


/// Botón para mostrar el modal de notas del curso
class ShowNotesModal extends StatelessWidget {

  final CoursePlayerController controller;
   
  const ShowNotesModal({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit_note, color: AppColors.primaryAccent),
      tooltip: 'Mis Notas',
      onPressed: () => _showNotesModal(context),
    );
  }

  // MODAL DE NOTAS
  void _showNotesModal(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6, // 60% del ancho de la pantalla
          height: MediaQuery.of(context).size.height * 0.8, // 80% del alto
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Cabecera del modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, color: AppColors.primaryAccent),
                      SizedBox(width: 8),
                      Text(
                        'Mis Notas',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('Exportar a Markdown'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: controller.exportCourseNotes,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 32),
              
              // Contenido de las notas (Editor / Vista Previa)
              Expanded(
                child: _buildNotesContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => ToggleButtons(
                isSelected: [!controller.isPreviewMode.value, controller.isPreviewMode.value],
                onPressed: (index) => controller.isPreviewMode.value = index == 1,
                color: Colors.grey,
                selectedColor: AppColors.primaryAccent,
                fillColor: AppColors.primaryAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
                children: const [
                  Text('Editar'),
                  Text('Vista Previa'),
                ],
              )),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isPreviewMode.value) {
              return _Preview(controller: controller);
            } else {
              return _TakeNoteView(controller: controller);
            }
          }),
        ),
      ],
    );
  }
}



/// Vista para tomar apuntes en Markdown.
class _TakeNoteView extends StatelessWidget {
  const _TakeNoteView({
    required this.controller,
  });

  final CoursePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller.notesController,
        maxLines: null,
        expands: true,
        style: const TextStyle(color: Colors.white, height: 1.5, fontFamily: 'Consolas'),
        decoration: const InputDecoration(
          hintText: 'Escribe tus apuntes aquí usando Markdown...\n\nEjemplo:\n# Tema Principal\nConcepto 1\nConcepto 2\n\n```dart\nprint("Hola");\n```',
          hintStyle: TextStyle(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        onChanged: (text) => controller.saveCurrentNotes(text),
      ),
    );
  }
}



/// Vista de previsualización de los apuntes en Markdown.
class _Preview extends StatelessWidget {
  const _Preview({
    required this.controller,
  });

  final CoursePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: MarkdownBody(
          data: controller.notesController.text.isEmpty
              ? '*No hay apuntes para esta lección aún.*'
              : controller.notesController.text,
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(Get.context!)).copyWith(
            p: const TextStyle(color: Colors.white70),
            h1: const TextStyle(color: Colors.white),
            h2: const TextStyle(color: Colors.white),
            h3: const TextStyle(color: Colors.white),
            listBullet: const TextStyle(color: AppColors.primaryAccent),
          ),
        ),
      ),
    );
  }
}