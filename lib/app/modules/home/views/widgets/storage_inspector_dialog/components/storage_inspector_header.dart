import 'package:flutter/material.dart';

class StorageInspectorHeader extends StatelessWidget {

  final VoidCallback onClose;
   
  const StorageInspectorHeader({
    super.key, 
    required this.onClose
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        const Text(
          'Inspector y Limpieza de Almacenamiento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: onClose,
        ),
        
      ],
    );
  }
}