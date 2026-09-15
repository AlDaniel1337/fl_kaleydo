// lib/app/global_widgets/game_cover_image.dart

import 'dart:io';
import 'package:flutter/material.dart';

/// Componente para mostrar la carátula o portada de un juego/medio con soporte
/// para esquinas redondeadas, interacción de toque y manejo de errores de archivo.
class GameCoverImage extends StatelessWidget {
  
  //+ VARIABLES
  final String? coverPath;
  final double innerImageBorderRadius;
  final VoidCallback? onPlayOrCancel;

  const GameCoverImage({
    super.key,
    this.coverPath,
    this.innerImageBorderRadius = 8.0,
    this.onPlayOrCancel,
  });
  //!+



  //+ ESTRUCTURA UI
  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(innerImageBorderRadius);
    final bool hasValidPath = coverPath != null && coverPath!.isNotEmpty;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPlayOrCancel,
          borderRadius: borderRadius,
          child: hasValidPath
            ? Image.file(
                File(coverPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                cacheWidth: 800, // Evita decodificar a resoluciones gigantes
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackContainer(),
              )
            : _buildFallbackContainer(),
        ),
      ),
    );
  }
  //!+



  //+ MÉTODOS AUXILIARES
  /// Contenedor de reserva cuando no hay imagen o ocurre un error al cargarla.
  Widget _buildFallbackContainer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white38,
          size: 24,
        ),
      ),
    );
  }
  //!+
}