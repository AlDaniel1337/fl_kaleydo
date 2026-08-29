import 'dart:io';

import 'package:kaleydo/app/config/enums/app_media_type.dart';


/// Modelo que representa un ítem de medio en la aplicación.
class MediaItemModel {
  final String id;
  final String title;
  final String path;
  final AppMediaType type;
  final String? coverPath;
  final bool isFavorite;
  final DateTime lastAccessed;

  MediaItemModel({
    required this.id,
    required this.title,
    required this.path,
    required this.type,
    this.coverPath,
    this.isFavorite = false,
    DateTime? lastAccessed,
  }) : lastAccessed = lastAccessed ?? DateTime.now();

  File? get coverFile => coverPath != null ? File(coverPath!) : null;
}