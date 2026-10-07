import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget optimizado para Windows que muestra la vista detallada de una imagen.
class ImageDetailView extends StatefulWidget {
  final int initialIndex;
  final List<String> imageUrls;

  const ImageDetailView({
    super.key,
    required this.initialIndex,
    required this.imageUrls,
  });

  @override
  State<ImageDetailView> createState() => _ImageDetailViewState();
}

class _ImageDetailViewState extends State<ImageDetailView> {
  late int currentIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void _nextImage() {
    if (currentIndex < widget.imageUrls.length - 1) {
      setState(() => currentIndex++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width * 0.8;
    final height = mediaQuery.size.height * 0.9;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _previousImage,
        const SingleActivator(LogicalKeyboardKey.keyA): _previousImage,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _nextImage,
        const SingleActivator(LogicalKeyboardKey.keyD): _nextImage,
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black.withAlpha((0.10 * 255).round()),
          body: Stack(
            children: [
              // Cierre al hacer clic únicamente en el fondo oscuro
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),

              // Imagen central (no propaga clics al fondo)
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(widget.imageUrls[currentIndex]),
                        height: height,
                        width: width,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Botón de cierre en la esquina superior derecha
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),

              // Indicador de posición
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Imagen ${currentIndex + 1} de ${widget.imageUrls.length}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ),

              // Botón de navegación previo
              if (currentIndex > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousImage,
                    ),
                  ),
                ),

              // Botón de navegación siguiente
              if (currentIndex < widget.imageUrls.length - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: IconButton.filledTonal(
                      iconSize: 32,
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextImage,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}