import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kaleydo/app/shared/widgets/dialogs/gallery_modal_dialog/components/image_detail_view.dart';


/// Widget que representa una miniatura de imagen en la galería. 
/// Al hacer clic, abre la vista detallada de la imagen.
class ImageTile extends StatelessWidget {
  final int index;
  final String heroTag;
  final List<String> imageUrls;

  const ImageTile({
    super.key, 
    required this.index, 
    required this.heroTag, 
    required this.imageUrls
  });

  //: Abre la vista detallada de la imagen seleccionada.
  void _openImageDetail(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black87,
        pageBuilder: (BuildContext context, _, _) {
          return ImageDetailView(
            initialIndex: index,
            imageUrls: imageUrls,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openImageDetail(context),
      child: Hero(
        tag: heroTag,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(imageUrls[index]),
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Imagen #${index + 1}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}