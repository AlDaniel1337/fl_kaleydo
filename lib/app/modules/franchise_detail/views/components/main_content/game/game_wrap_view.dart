import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/components.index.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/small_game_card.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/main_content/game/game_card/widgets/game_info_section.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

class GameWrapView extends StatelessWidget {
  final List<FranchiseItemModel> items;
  final bool isNovel;
  final VoidCallback? onExecute;
  final Function(FranchiseItemModel) setSelectedGameItem;
  final String selectedGameItemInfo;
  final List<String> selectedGameItemTags;
  final List<String> selectedGameItemImages;
  final VoidCallback? onShowCGsGallery;
  final VoidCallback? onShowGuide;

  const GameWrapView({
    super.key,
    required this.items,
    required this.isNovel,
    required this.onExecute,
    required this.setSelectedGameItem,
    required this.selectedGameItemInfo,
    required this.selectedGameItemTags,
    required this.selectedGameItemImages,
    this.onShowCGsGallery,
    this.onShowGuide,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40,),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          //: Tarjeta principal del juego seleccionado
          SizedBox(
            width: 280,
            height: 430,
            child: GameCard(
              game: items.first,
              isNovel: isNovel,
              onExecute: onExecute,
              onShowCGsGallery: onShowCGsGallery,
              onShowGuide: onShowGuide,
            ),
          ),
          const SizedBox(width: 20),

          //: Contenido e información adicional
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedGameItemInfo.isNotEmpty)
                  GameInfoSection(info: selectedGameItemInfo),

                if (selectedGameItemTags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  CustomTagsSection(tags: selectedGameItemTags),
                ],

                if (selectedGameItemImages.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _GameImagesGallery(images: selectedGameItemImages),
                ],

                if (items.length > 1) ...[
                  const SizedBox(height: 15),
                  _MoreGamesSection(
                    items: items,
                    isNovel: isNovel,
                    onSelectGame: setSelectedGameItem,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}



/// Sección de galería de imágenes del juego seleccionado
class _GameImagesGallery extends StatelessWidget {
  final List<String> images;

  const _GameImagesGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: images.map((imagePath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(imagePath),
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            cacheWidth: 400,
          ),
        );
      }).toList(),
    );
  }
}



/// Sección de "Más juegos" relacionados con el juego seleccionado
class _MoreGamesSection extends StatefulWidget {
  final List<FranchiseItemModel> items;
  final bool isNovel;
  final Function(FranchiseItemModel) onSelectGame;

  const _MoreGamesSection({
    required this.items,
    required this.isNovel,
    required this.onSelectGame,
  });

  @override
  State<_MoreGamesSection> createState() => _MoreGamesSectionState();
}

class _MoreGamesSectionState extends State<_MoreGamesSection> {
  final ScrollController _scrollController = ScrollController();

  // Dimensiones exactas basadas en tus Tarjetas y Wrap
  static const double _cardHeight = 200.0;
  static const double _runSpacing = 20.0;

  void _scrollByRow(bool forward) {
    if (!_scrollController.hasClients) return;

    // Distancia exacta para avanzar/retroceder una fila (220px)
    final double rowOffset = _cardHeight + _runSpacing;
    final double targetOffset = forward
        ? _scrollController.offset + rowOffset
        : _scrollController.offset - rowOffset;

    final double clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Separador con título y botones opcionales
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Más juegos',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 10),

        // Contenedor con scroll snap por filas
        Listener(
          onPointerSignal: (pointerSignal) {
            if (pointerSignal is PointerScrollEvent) {
              if (pointerSignal.scrollDelta.dy > 0) {
                _scrollByRow(true);  // Bajar 1 fila completa
              } else if (pointerSignal.scrollDelta.dy < 0) {
                _scrollByRow(false); // Subir 1 fila completa
              }
            }
          },
          child: SizedBox(
            height: _cardHeight, // Muestra exactamente 1 fila a la vez
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const NeverScrollableScrollPhysics(), // Bloquea el scroll continuo
              child: Wrap(
                alignment: WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 20,
                runSpacing: _runSpacing,
                children: widget.items.map((item) {
                  return SizedBox(
                    width: 120,
                    height: _cardHeight,
                    child: SmallGameCard(
                      game: item,
                      isNovel: widget.isNovel,
                      showButtons: false,
                      onTap: () => widget.onSelectGame(item),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}