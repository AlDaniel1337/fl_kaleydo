import 'package:flutter/material.dart';

class SidebarCategoryModel {
  final String rawFolderName; // Ej: "_animes" o "_musica"
  final String displayName;   // Ej: "Animes" o "Musica"
  final IconData icon;
  final bool isKnown;         // true si está en la lista predefinida

  SidebarCategoryModel({
    required this.rawFolderName,
    required this.displayName,
    required this.icon,
    this.isKnown = true,
  });
}