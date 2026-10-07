import 'package:flutter/material.dart';
import 'package:kaleydo/app/shared/widgets/dialogs/gallery_modal_dialog/components/image_tile.dart';

/// Widget que muestra un diálogo modal con una galería de imágenes.
class GalleryModalDialog extends StatefulWidget {

  final List<String> imageUrls;

  const GalleryModalDialog({super.key, required this.imageUrls});

  @override
  State<GalleryModalDialog> createState() => _GalleryModalDialogState();
}

class _GalleryModalDialogState extends State<GalleryModalDialog> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            //: Encabezado del Modal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Galería (${widget.imageUrls.length} imágenes)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            
            //: Grilla de Imágenes con Scrollbar
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                interactive: true,
                child: GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    final heroTag = 'gallery_image_$index';
                    return ImageTile(
                      index: index,
                      heroTag: heroTag,
                      imageUrls: widget.imageUrls,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}