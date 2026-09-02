import 'package:flutter/material.dart';

/// Helper que proporciona utilidades para la posición de los botones en los diálogos del reproductor.
abstract class PlayerDialogHelper {
  static RelativeRect getButtonPosition(
    BuildContext buttonContext, {
    double verticalOffset = 200.0,
  }) {
    
    // Obtiene la posición del botón en relación con el overlay.
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

    final Offset buttonTopLeft =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Offset buttonBottomRight =
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay);

    // Aplica el desplazamiento vertical al rectángulo del botón.
    final Rect shiftedRect = Rect.fromLTRB(
      buttonTopLeft.dx,
      buttonTopLeft.dy - verticalOffset,
      buttonBottomRight.dx,
      buttonBottomRight.dy - verticalOffset,
    );
    
    // Devuelve la posición relativa del botón dentro del overlay.
    return RelativeRect.fromRect(
      shiftedRect,
      Offset.zero & overlay.size,
    );
  }
}