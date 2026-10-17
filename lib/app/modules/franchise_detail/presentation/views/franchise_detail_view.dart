import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/controllers/franchise_detail_controller.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/views/widgets/components.index.dart';
import 'package:kaleydo/app/shared/widgets/dialogs/gallery_modal_dialog/gallery_modal_dialog.dart';

class FranchiseDetailView extends GetView<FranchiseDetailController> {
  static const String route = "/franchise-detail";

  const FranchiseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final paginatorSize = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          );
        }

        return Column(
          children: [
            // 1. Banner Superior con degradado y controles
            _buildHeaderBanner(),

            // 2. Selector de Pestañas Dinámicas
            _buildTabSelector(),

            // 3. Sub-header para Selector de Temporadas de Anime
            if (controller.showAnimeSeasonTabs()) _buildSeasonSelector(),

            // 4. Banner de "Continuar"
            _buildResumeBanner(),

            // 5. Vista de Contenido Dinámica
            Expanded(child: _buildMainContent(paginatorSize, context)),
          ],
        );
      }),
    );
  }

  /// Banner superior independiente de los sub-controllers
  Widget _buildHeaderBanner() {
    return HeaderBanner(
      coverImage: controller.mediaItem.coverPath != null
          ? DecorationImage(
              image: FileImage(File(controller.mediaItem.coverPath!)),
              fit: BoxFit.cover,
            )
          : null,
      onBackPressed: () => Get.back(),
      onRefresh: () => controller.refreshFranchiseContent(),
      itemPath: controller.mediaItem.path,
      title: controller.mediaItem.title,
      onOpenFolder: () =>
          controller.openFranchiseFolder(controller.mediaItem.path),
    );
  }

  /// Selector de pestañas delegando el scroll reset a AnimeController
  Widget _buildTabSelector() {
    return TabSelector(
      availableTabs: controller.availableMediaCategories,
      selectedTab: controller.selectedCategory.value,
      onTabSelected: (tab) {
        controller.selectedCategory.value = tab;
        controller.animeController.moveScrollToTop();
      },
    );
  }

  /// Selector de temporadas delegando a `AnimeTabController`
  Widget _buildSeasonSelector() {
    return SeasonSelector(
      animeSeasons: controller.animeController.animeSeasons,
      selectedAnimeSeason: controller.animeController.selectedAnimeSeason.value,
      changeAnimeSeason: (season) =>
          controller.animeController.changeSeason(season),
    );
  }

  /// Paginador delegando a `MangaTabController`
  Widget _buildMangaPageSelector(double paginatorSize) {
    const margin = 150.0;

    return SizedBox(
      width: paginatorSize - margin,
      child: BookPaginator(
        totalItems: controller.mangaChapters.length,
        itemsPerPage: controller.mangaController.pageSize,
        selectedPageIndex: controller.mangaController.currentPageIndex.value,
        onPageSelected: (pageIndex) {
          controller.mangaController.changePage(pageIndex, () {
            controller.animeController.moveScrollToTop();
          });
        },
      ),
    );
  }

  /// Banner para reanudar el último progreso guardado
  Widget _buildResumeBanner() {
    final progress = controller.latestProgress.value;
    if (progress == null) return const SizedBox.shrink();

    final String title = progress['lastChapterTitle'] ??
        progress['lastVideoTitle'] ??
        'Continuar';

    return ResumeBanner(
      title: title,
      onResume: () {
        FocusManager.instance.primaryFocus?.unfocus();
        controller.resumeLastProgress();
      },
    );
  }

  /// Vista Principal según el tab activo
  Widget _buildMainContent(double paginatorSize, BuildContext context) {
    final tab = controller.selectedCategory.value;
    final items = controller.mediaContent[tab] ?? [];

    //: Juegos / Novelas Visuales -> Usa gameController
    if (tab == FranchiseMediaType.juegos || tab == FranchiseMediaType.novelasVisuales) {

        return GameWrapView(
        items: items,
        selectedGameItemIndex: controller.gameController.selectedGameItemIndex.value,
        isNovel: tab == FranchiseMediaType.novelasVisuales,
        onExecute: () => controller.gameController.launchExecutable(
          controller.gameController.selectedGameItem?.executablePath ?? '',
        ),
        setSelectedGameItem: (item, index) =>
          controller.gameController.setSelectedGameItem(item, index),
        selectedGameItemInfo: controller.gameController.selectedGameItemInfo.value,
        selectedGameItemTags: controller.gameController.selectedGameItemTags,
        selectedGameItemImages: controller.gameController.randomSelectedGameItemImages,
        onShowCGsGallery: () => _openGalleryModal(
          context: context,
          imageUrls: controller.gameController.selectedGameItemImages,
        ),
      );
    }

    //: Manga -> Usa mangaController
    if (tab == FranchiseMediaType.manga) {
      final paginatedChapters = controller.mangaController.getPaginatedChapters(
        chapters: controller.mangaChapters,
        pageIndex: controller.mangaController.currentPageIndex.value,
      );

      return Column(
        children: [
          BookSubHeader(
            isMangaGridView: controller.mangaController.isGridView.value,
            onToggleView: controller.mangaController.toggleViewMode,
            pageSelector: _buildMangaPageSelector(paginatorSize),
          ),
          Expanded(
            child: controller.mangaController.isGridView.value
                ? BookGridView(
                    items: paginatedChapters,
                    onTap: (index) {
                      controller.openReaderForChapter(
                          controller.mangaChapters, index);
                    },
                  )
                : BookListView(
                    items: paginatedChapters,
                    onTap: (index) {
                      controller.openReaderForChapter(
                          controller.mangaChapters, index);
                    },
                    isBook: false,
                  ),
          ),
        ],
      );
    }

    //: Manga H -> Usa mangaController
    if (tab == FranchiseMediaType.mangah) {
      final paginatedChapters = controller.mangaController.getPaginatedChapters(
        chapters: controller.mangaHChapters,
        pageIndex: controller.mangaController.currentPageIndex.value,
      );

      return BookGridView(
        items: paginatedChapters,
        onTap: (index) {
          controller.openReaderForChapter(controller.mangaHChapters, index);
        },
      );
    }

    //: Libros / Novelas Ligeras
    if (tab == FranchiseMediaType.libros) {
      return BookListView(
        items: items,
        onTap: (index) {
          controller.openReaderForChapter(controller.bookItems, index);
        },
        isBook: true,
      );
    }

    //: Anime / Video -> Usa animeController
    if (tab == FranchiseMediaType.anime) {
      final episodes = controller.filteredAnimeEpisodes;
      return VideoListView(
        controller: controller.animeController.animeScrollController,
        episodes: episodes,
        onEpisodeTap: (idx) {
          controller.openPlayerForEpisode(
              controller.filteredAnimeEpisodes, idx);
        },
      );
    }

    return const Center(
      child: Text(
        'Vista de Resumen en Markdown',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}

void _openGalleryModal({
  required BuildContext context,
  required List<String> imageUrls,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return GalleryModalDialog(imageUrls: imageUrls);
    },
  );
}