import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/header_banner/media_action_buttons.dart';

class HeaderBanner extends StatelessWidget {

  final DecorationImage? coverImage;
  final VoidCallback? onBackPressed;
  final VoidCallback? onRefresh; 
  final VoidCallback? onOpenFolder; 
  final String title; 
  final String itemPath; 
   
  const HeaderBanner({
    super.key,
    this.coverImage,
    this.onBackPressed,
    this.onRefresh,
    this.onOpenFolder,
    required this.itemPath,
    required this.title,
  });
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        //: Banner
        // Contenedor del banner con la imagen de portada y degradado
        Container(
          height: 130,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            image: coverImage,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  AppColors.background.withValues(alpha: 0.9),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        //: Botón de Regresar
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBackPressed,
          ),
        ),

        //: Botón de Favorito y En Proceso
        Positioned(
          top: 16,
          right: 150,
          child: MediaActionButtons(
            itemPath: itemPath,
          )
        ),

        //: Botón de recargar
        Positioned(
          top: 16,
          right: 20, 
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            tooltip: 'Re-escanear contenido',
            onPressed: onRefresh,
          ),
        ),
        
        
        //: Botón 
        Positioned(
          top: 16,
          right: 60, 
          child: IconButton(
            icon: const Icon(Icons.folder_open_rounded),
            tooltip: 'Abrir ubicación del archivo',
            color: Colors.white,
            onPressed: onOpenFolder,
          ),
        ),

            
        //: Título de la Franquicia
        Positioned(
          top: 70,
          left: 34,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}