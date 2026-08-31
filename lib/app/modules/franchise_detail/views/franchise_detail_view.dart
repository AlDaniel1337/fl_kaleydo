import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/controllers/franchise_detail_controller.dart';

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

            // 4. Vista de Contenido Dinámica
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
          height: 220,
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

    // Vista de Lista para Manga y Novelas Ligeras / Libros
    if (tab == FranchiseMediaType.manga || tab == FranchiseMediaType.libros) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: items.length,
        itemBuilder: (ctx, idx) => _buildBookOrMangaTile(items[idx], tab == FranchiseMediaType.libros),
      );
    }

    // Vista de Lista para Anime
    if (tab == FranchiseMediaType.anime) {
      final episodes = controller.filteredAnimeEpisodes;
      return ListView.builder(
        controller: controller.animeScrollController, // Vinculación del ScrollController
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: episodes.length,
        itemBuilder: (ctx, idx) => _buildAnimeTile(episodes[idx]),
      );
    }

    return const Center(
      child: Text('Vista de Resumen en Markdown', style: TextStyle(color: AppColors.textSecondary)),
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

  Widget _buildBookOrMangaTile(FranchiseItemModel item, bool isBook) {
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
              : (item.pagePaths.first.endsWith('.pdf')
                  ? 'Documento PDF'
                  : '${item.pagePaths.length} Páginas'),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () {
          // Navegación al Lector de Libros/Manga
        },
      ),
    );
  }

  Widget _buildAnimeTile(FranchiseItemModel episode) {
    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.play_circle_fill, color: AppColors.primaryAccent),
        title: Text(episode.title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(episode.seasonName ?? 'Anime', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        onTap: () {
          // Navegación al Reproductor de Video
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
}