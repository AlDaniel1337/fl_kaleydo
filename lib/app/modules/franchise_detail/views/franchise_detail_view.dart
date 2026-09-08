import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/controllers/franchise_detail_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

class FranchiseDetailView extends GetView<FranchiseDetailController> {
  static const String route = "/franchise-detail";

  const FranchiseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
        }

        return Column(
          children: [
            // 1. Banner Superior con degradado y controles
            _buildHeaderBanner(),

            // 2. Selector de Pestañas Dinámicas
            _buildTabSelector(),

            // 3. Sub-header para Selector de Temporadas de Anime
            if (controller.showAnimeSeasonTabs())
              _buildSeasonSelector(),

            // 4. Banner de "Continuar" (Nuevo)
            _buildResumeBanner(),

            // 5. Vista de Contenido Dinámica
            Expanded(child: _buildMainContent()),
          ],
          
        );
      }),
    );
  }

  Widget _buildHeaderBanner() {
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            image: controller.mediaItem.coverPath != null
                ? DecorationImage(
                    image: FileImage(File(controller.mediaItem.coverPath!)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  AppColors.background.withOpacity(0.9),
                  AppColors.background,
                ],
              ),
            ),
          ),
        ),

        // Botón de Regresar
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),

        // Botón de Favorito y En Proceso
        Positioned(
          top: 16,
          right: 16,
          child: MediaActionButtons(
            itemPath: controller.mediaItem.path,
          )
        ),
            


        // Título de la Franquicia
        Positioned(
          bottom: 16,
          left: 24,
          child: Text(
            controller.mediaItem.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 12,
        children: controller.availableTabs.map((tab) {
          final isSelected = controller.selectedTab.value == tab;
          return ChoiceChip(
            label: Text(_getTabName(tab)),
            selected: isSelected,
            selectedColor: AppColors.primaryAccent,
            backgroundColor: AppColors.cardBackground,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            onSelected: (_) {
              controller.selectedTab.value = tab;
              controller.moveScrollToTop();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSeasonSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Row(
        children: controller.animeSeasons.map((season) {
          final isSelected = controller.selectedAnimeSeason.value == season;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(season),
              selected: isSelected,
              selectedColor: const Color(0xFF2B2845),
              backgroundColor: AppColors.sidebarBackground,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
                fontSize: 12,
              ),
              onSelected: (_) => controller.changeAnimeSeason(season), // Usar método del controller
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGameCard(FranchiseItemModel game, bool isNovel) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF201D33),
                image: game.coverPath != null
                    ? DecorationImage(
                        image: FileImage(File(game.coverPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            game.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: game.executablePath != null
                    ? () => controller.launchExecutable(game.executablePath!)
                    : null,
                icon: const Icon(Icons.play_arrow, size: 14),
                label: const Text('Jugar', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              if (isNovel && game.hasCgs) ...[
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('CGs', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
              if (isNovel && game.hasGuide) ...[
                const SizedBox(width: 4),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Guía', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBookOrMangaTile(FranchiseItemModel item, bool isBook, int index) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isBook ? Icons.chrome_reader_mode_rounded : Icons.menu_book_rounded,
          color: AppColors.primaryAccent,
        ),
        title: Text(item.title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(
          isBook
              ? 'Novela Ligera / Libro'
              : (item.pagePaths.isNotEmpty && item.pagePaths.first.endsWith('.pdf')
                  ? 'Documento PDF'
                  : '${item.pagePaths.length} Páginas'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {
          // Seleccionamos la lista según el medio actual (Libro vs Manga)
          final List<FranchiseItemModel> currentList = isBook 
              ? controller.bookItems 
              : controller.mangaChapters;

          controller.openReaderForChapter(currentList, index);
        },
      ),
    );
  }

  Widget _buildAnimeTile(FranchiseItemModel episode, int index) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill, color: AppColors.primaryAccent),
        title: Text(episode.title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(episode.seasonName ?? 'Anime',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          controller.openPlayerForEpisode(controller.filteredAnimeEpisodes, index);
        },
      ),
    );
  }

  String _getTabName(FranchiseMediaType type) {
    switch (type) {
      case FranchiseMediaType.juegos:  return 'Juegos';
      case FranchiseMediaType.novelas: return 'Novelas Visuales';
      case FranchiseMediaType.libros:  return 'Libros';
      case FranchiseMediaType.manga:   return 'Manga';
      case FranchiseMediaType.anime:   return 'Anime';
      case FranchiseMediaType.resumen: return 'Resumen';
    }
  }

  /// Widget del banner para continuar la lectura o reproducción
  Widget _buildResumeBanner() {
    return Obx(() {
      final progress = controller.latestProgress.value;
      if (progress == null) return const SizedBox.shrink();

      final String title = progress['lastChapterTitle'] ?? progress['lastVideoTitle'] ?? 'Continuar';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryAccent.withOpacity(0.2), AppColors.cardBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_filled_rounded, color: AppColors.primaryAccent, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso guardado en esta categoría',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 14),
              label: const Text('Continuar', style: TextStyle(fontSize: 12)),
              onPressed: () => controller.resumeLastProgress(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMainContent() {
    final tab = controller.selectedTab.value;
    final items = controller.mediaContent[tab] ?? [];

    // Vista Grid para Juegos y Novelas Visuales
    if (tab == FranchiseMediaType.juegos || tab == FranchiseMediaType.novelas) {
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (ctx, idx) => _buildGameCard(items[idx], tab == FranchiseMediaType.novelas),
      );
    }

    // Vista de Manga con opción de alternar entre Lista y Grid
    if (tab == FranchiseMediaType.manga) {
      return Column(
        children: [
          // Barra superior con botón para cambiar la vista (Lista / Grid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => ToggleButtons(
                  isSelected: [!controller.isMangaGridView.value, controller.isMangaGridView.value],
                  onPressed: (_) => controller.toggleMangaView(),
                  color: AppColors.textSecondary,
                  selectedColor: Colors.white,
                  fillColor: AppColors.primaryAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  constraints: const BoxConstraints(minHeight: 32, minWidth: 40),
                  children: const [
                    Tooltip(message: 'Vista de lista', child: Icon(Icons.list_rounded, size: 18)),
                    Tooltip(message: 'Vista de cuadrícula', child: Icon(Icons.grid_view_rounded, size: 18)),
                  ],
                )),
              ],
            ),
          ),
          
          // Contenido dinámico (Grid o Lista)
          Expanded(
            child: Obx(() => controller.isMangaGridView.value
                ? _buildMangaGridView(controller.mangaChapters)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    itemCount: items.length,
                    itemBuilder: (ctx, idx) => _buildBookOrMangaTile(items[idx], false, idx),
                  )),
          ),
        ],
      );
    }

    // Vista de Lista para Libros (Novelas Ligeras)
    if (tab == FranchiseMediaType.libros) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: items.length,
        itemBuilder: (ctx, idx) => _buildBookOrMangaTile(items[idx], true, idx),
      );
    }

    // Vista de Lista para Anime
    if (tab == FranchiseMediaType.anime) {
      final episodes = controller.filteredAnimeEpisodes;
      return ListView.builder(
        controller: controller.animeScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: episodes.length,
        itemBuilder: (ctx, idx) => _buildAnimeTile(episodes[idx], idx),
      );
    }

    return const Center(
      child: Text('Vista de Resumen en Markdown', style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  /// Widget de Cuadrícula para los capítulos de Manga
  Widget _buildMangaGridView(List<FranchiseItemModel> chapters) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, // 5 columnas de capítulos
        childAspectRatio: 0.7, // Proporción vertical típica de manga
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: chapters.length,
      itemBuilder: (ctx, idx) {
        final chapter = chapters[idx];
        final String? firstImage = chapter.pagePaths.isNotEmpty ? chapter.pagePaths.first : null;

        return InkWell(
          onTap: () {
            Get.toNamed(
              '/reader',
              arguments: {
                'chapterList': chapters,
                'currentIndex': idx,
              },
            );
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen de la primera página como miniatura
                Expanded(
                  child: firstImage != null
                      ? Image.file(
                          File(firstImage),
                          fit: BoxFit.cover,
                          cacheWidth: 300,
                        )
                      : Container(
                          color: Colors.black26,
                          child: const Icon(Icons.broken_image_rounded, color: Colors.white54),
                        ),
                ),
                // Título del capítulo
                Container(
                  padding: const EdgeInsets.all(8),
                  color: AppColors.cardBackground,
                  child: Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}