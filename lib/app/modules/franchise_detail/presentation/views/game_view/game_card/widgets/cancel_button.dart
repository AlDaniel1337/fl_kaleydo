// lib/app/global_widgets/cancel_button.dart

import 'package:flutter/material.dart';

/// Botón compacto de cancelación estilizado para interrumpir acciones o temporizadores.
class CancelButton extends StatelessWidget {
  
  //+ VARIABLES
  final VoidCallback onCancelCountdown;

  const CancelButton({
    super.key,
    required this.onCancelCountdown,
  });
  //!+



  //+ ESTRUCTURA UI
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        onPressed: onCancelCountdown,
        icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
        tooltip: 'Cancelar inicio',
        style: IconButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  //!+
}