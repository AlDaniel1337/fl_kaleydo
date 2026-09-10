import 'package:flutter/material.dart';

class StorageInspectorFooter extends StatelessWidget {
  final VoidCallback onClearAll;

  const StorageInspectorFooter({
    super.key,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          icon: const Icon(Icons.delete_forever_rounded),
          label: const Text('Limpiar Todo el Storage'),
          onPressed: onClearAll,
        ),
      ],
    );
  }
}