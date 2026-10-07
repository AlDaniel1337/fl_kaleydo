import 'package:flutter/material.dart';

/// Sección de etiquetas personalizadas
class CustomTagsSection extends StatelessWidget {
  final List<String> tags;

  const CustomTagsSection({
    super.key, 
    required this.tags
  });

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: 35,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 5,
          runSpacing: 5,
          children: tags.map(
            (tag) => Chip(
              label: Text(
                tag.trim(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }
}