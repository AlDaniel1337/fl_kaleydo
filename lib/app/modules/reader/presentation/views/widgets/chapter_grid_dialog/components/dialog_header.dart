import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/reader/presentation/controllers/reader_controller.dart';

/// Encabezado del diálogo que muestra: 
/// - El número de páginas
/// - Un botón para cerrar el diálogo.
class DialogHeader extends StatelessWidget {
  const DialogHeader({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        //: Título del diálogo
        Text(
          'Páginas (${controller.imagePaths.length})',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        //: Botón de cerrar el diálogo
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Get
          .back(),
        ),
      ],
    );
  }
}