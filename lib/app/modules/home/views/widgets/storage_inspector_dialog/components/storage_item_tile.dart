import 'package:flutter/material.dart';

class StorageItemTile extends StatelessWidget {
  final String displayText;
  final VoidCallback onDelete;

  const StorageItemTile({
    super.key,
    required this.displayText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              displayText,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent, size: 16),
            tooltip: 'Eliminar este elemento',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}