import 'package:flutter/material.dart';
import 'dart:io';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'cover_placeholder.dart';
import 'dart:ui' show ImageFilter;



/// Widget que muestra la imagen de portada de un elemento de medios.
/// Si no hay una imagen disponible, se muestra un placeholder.
class CoverImage extends StatelessWidget {
   
  final MediaItemModel item;

  const CoverImage({
    super.key, 
    required this.item
  });
  
  @override
  Widget build(BuildContext context) {
    return HoverableContentCard(
      item: item,
    );     
  }   
}



/// Widget que muestra una tarjeta de contenido que responde al hover.
class HoverableContentCard extends StatefulWidget {
  final MediaItemModel item; 
  final bool useBlurEffect;

  const HoverableContentCard({super.key, required this.item, this.useBlurEffect = false});

  @override
  State<HoverableContentCard> createState() => _HoverableContentCardState();
}



class _HoverableContentCardState extends State<HoverableContentCard> {
  
  //: Variable de estado para rastrear si el cursor está sobre el widget
  bool _isHovering = false;

  //: Parámetros de la animación
  final Duration _animationDuration = const Duration(milliseconds: 200);
  final Curve _animationCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    
    final item = widget.item;

    return MouseRegion(

      //: Detectar cuando entra y sale el puntero
      onEnter: (_) => setState(() => _isHovering = true),
      onExit:  (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // Cambia el cursor para indicar que es clickeable
      
      //: Asegura que los efectos (zoom) no se salgan del contenedor principal
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Ajusta el radio según tu diseño
        child: Stack(
          children: [
            
            //: Imagen de portada (CON ZOOM Y BLUR)
            Positioned.fill(
              // Widget de animación para la escala y el desenfoque
              child: AnimatedScale(
                // Aplicar Zoom: escala más grande si hay hover
                scale: _isHovering ? 1.10 : 1.0, // 10% de zoom
                duration: _animationDuration,
                curve: _animationCurve,
                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    //: Imagen de fondo
                    BackgroundImage(item: item),
                    
                    //: Aplicar Blur: Solo si hay hover y si useBlurEffect es verdadero
                    if (_isHovering && widget.useBlurEffect)
                      Positioned.fill(
                        child: BackdropFilter(
                          // Intensidad del desenfoque
                          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                          child: Container(
                            // Capa invisible necesaria para BackdropFilter
                            color: Colors.black.withValues(alpha: 0.0), 
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            //: Título inferior (fijo)
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: BottomTitle(item: item),
            ),
          ],
        ),
      ),
    );
  }
}



/// Widget que muestra el título inferior de un elemento
class BottomTitle extends StatelessWidget {
  const BottomTitle({
    super.key,
    required this.item,
  });

  final MediaItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.cardBackgroundSemiTransparent,
      child: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}



/// Widget que muestra la imagen de fondo
class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    super.key,
    required this.item,
  });

  final MediaItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF201D33),
      child: item.coverPath != null
        ? Image.file(
            File(item.coverPath!),
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stack) => const CoverPlaceholder() )
        : const CoverPlaceholder(),
    );
  }
}