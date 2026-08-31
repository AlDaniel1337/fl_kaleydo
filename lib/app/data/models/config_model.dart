import 'dart:convert';



/// Modelo de configuración de la aplicación, que incluye rutas y extensiones de archivos.
class ConfigModel {
  String rootFolderPath;
  List<String> videoExtensions;
  List<String> imageExtensions;
  List<String> audioExtensions;
  List<String> documentExtensions;
  List<String> executableExtensions;

  ConfigModel({
    required this.rootFolderPath,
    required this.videoExtensions,
    required this.imageExtensions,
    required this.audioExtensions,
    required this.documentExtensions,
    required this.executableExtensions,
  });

  factory ConfigModel.defaultConfig() {
    return ConfigModel(
      rootFolderPath: '',
      videoExtensions:      ['.mp4', '.mkv', '.avi', '.webm'],
      imageExtensions:      ['.jpg', '.jpeg', '.png', '.webp'],
      audioExtensions:      ['.mp3', '.flac', '.wav', '.ogg'],
      documentExtensions:   ['.pdf', '.cbz', '.cbr', '.epub', '.md'],
      executableExtensions: ['.exe', '.lnk', '.url'],
    );
  }

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      rootFolderPath: json['rootFolderPath'] ?? '',
      videoExtensions: List<String>.from(json['videoExtensions'] ?? []),
      imageExtensions: List<String>.from(json['imageExtensions'] ?? []),
      audioExtensions: List<String>.from(json['audioExtensions'] ?? []),
      documentExtensions: List<String>.from(json['documentExtensions'] ?? []),
      executableExtensions: List<String>.from(json['executableExtensions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'rootFolderPath': rootFolderPath,
        'videoExtensions': videoExtensions,
        'imageExtensions': imageExtensions,
        'audioExtensions': audioExtensions,
        'documentExtensions': documentExtensions,
        'executableExtensions': executableExtensions,
      };

  String toRawJson() => json.encode(toJson());
}