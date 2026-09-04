import 'package:flutter/material.dart';

/// Clase abstracta estática que sirve como utilidad para calcular y posicionar
/// menús flotantes (como [showMenu]) sobre los botones del reproductor de medios.
abstract class PlayerDialogHelper {
  
  /// Calcula la posición relativa ([RelativeRect]) que necesita un menú contextual
  /// para desplegarse alineado a un widget de origen ([buttonContext]).
  /// 
  /// [buttonContext]: El BuildContext del botón que activa el menú.
  /// [verticalOffset]: La distancia vertical (en píxeles) para elevar o desplazar el menú.
  static RelativeRect getButtonPosition(
    BuildContext buttonContext, {
    double verticalOffset = 200.0,
  }) {
    
    // 1. Obtiene el RenderBox del botón que recibió el toque/click.
    // Esto nos da acceso a sus dimensiones físicas (ancho/alto) en el árbol de renderizado.
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;

    // 2. Obtiene el RenderBox del Overlay principal de la pantalla.
    // El Overlay es la capa donde se dibujan los menús flotantes y diálogos.
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

    // 3. Convierte las coordenadas locales del botón a coordenadas globales relativas al Overlay.
    // 'buttonTopLeft' representa la esquina superior izquierda del botón.
    final Offset buttonTopLeft =
        button.localToGlobal(Offset.zero, ancestor: overlay);

    // 'buttonBottomRight' representa la esquina inferior derecha del botón.
    final Offset buttonBottomRight =
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay);

    // 4. Crea un área rectangular ([Rect]) ajustando la posición con los desplazamientos deseados.
    final Rect shiftedRect = Rect.fromLTRB(
      buttonTopLeft.dx + 40,                    // Lado Izquierdo: Mantiene la alineación del botón.
      buttonTopLeft.dy - verticalOffset,        // Lado Superior: Resta el offset para desplegar el menú MÁS ARRIBA del botón.
      buttonBottomRight.dx - 18,                // Lado Derecho: Recorta 18px a la derecha para un ajuste fino de margen.
      buttonBottomRight.dy - verticalOffset,    // Lado Inferior: Resta el offset para mantener la altura coherente.
    );

    // 5. Convierte el rectángulo modificado a un [RelativeRect], que mide las distancias 
    // desde los 4 bordes del Overlay (left, top, right, bottom).
    // Esto es exactamente lo que requiere la función `showMenu` en la propiedad `position`.
    return RelativeRect.fromRect(
      shiftedRect,
      Offset.zero & overlay.size, // Define los límites totales de la pantalla (de (0,0) al tamaño total del overlay)
    );
  }
}