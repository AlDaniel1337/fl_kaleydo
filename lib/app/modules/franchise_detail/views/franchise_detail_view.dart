import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/controllers/franchise_detail_controller.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/components/components.index.dart';

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
            Expanded(child: _buildMainContent( paginatorSize )),
          ],
          
        );
      }),
    );
    
  }



  /// Construye el banner superior con la imagen de portada, el botón de regresar y los botones de acción.
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
    );
  }


  /// Construye el selector de pestañas dinámicas basado en los tipos de medios disponibles.
  Widget _buildTabSelector() {
    return TabSelector(
      availableTabs: controller.availableTabs,
      selectedTab: controller.selectedTab.value,
      onTabSelected: (tab) {
        controller.selectedTab.value = tab;
        controller.moveScrollToTop();
      },
    );
  }


  /// Construye el selector de temporadas de anime.
  Widget _buildSeasonSelector() {
    return SeasonSelector(
      animeSeasons: controller.animeSeasons,
      selectedAnimeSeason: controller.selectedAnimeSeason.value,
      changeAnimeSeason: (season) => controller.changeAnimeSeason(season),
    );
  }


  /// Construye un selector de capítulos de manga/comic/manhwa
  Widget _buildMangaPageSelector( double paginatorSize ) {

    double margin = 150;

    return SizedBox(
      width: paginatorSize - margin,
      child: BookPaginator(
        totalItems: controller.mangaChapters.length,
        itemsPerPage: controller.comicsPerPageSize,
        selectedPageIndex: controller.currentMangaPageIndex.value,
        onPageSelected: (pageIndex) {
          controller.changeMangaPage(pageIndex);
        },
      ),
    );
  }

  
  /// Widget del banner para continuar la lectura o reproducción
  Widget _buildResumeBanner() {

    final progress = controller.latestProgress.value;

    if (progress == null) return const SizedBox.shrink();

    final String title = progress['lastChapterTitle'] ?? progress['lastVideoTitle'] ?? 'Continuar';
      
    return ResumeBanner(
      title: title,
      onResume: () {
        FocusManager.instance.primaryFocus?.unfocus();
        controller.resumeLastProgress();
      },
    );
    
  }


  ///: Vista Principal
  Widget _buildMainContent( double paginatorSize ) {
    final tab = controller.selectedTab.value;
    final items = controller.mediaContent[tab] ?? [];

    //: Juego
    if (tab == FranchiseMediaType.juegos || tab == FranchiseMediaType.novelas) {
      return GameWrapView(
        items: items,
        isNovel: tab == FranchiseMediaType.novelas,
        launchExecutable: (executablePath) => controller.launchExecutable(executablePath),
      );
    }

    // Vista de Manga con opción de alternar entre Lista y Grid
    if (tab == FranchiseMediaType.manga) {
      final paginatedChapters = controller.paginatedMangaChapters(
        pageIndex: controller.currentMangaPageIndex.value,
      );

      return Column(
        children: [
          // Barra superior con botón para cambiar la vista (Lista / Grid)
          BookSubHeader(
            isMangaGridView: controller.isMangaGridView.value,
            onToggleView: controller.toggleMangaView,
            pageSelector: _buildMangaPageSelector( paginatorSize ),
          ),
          
          // Contenido dinámico (Grid o Lista)
          Expanded(
            child: controller.isMangaGridView.value
              ? BookGridView(
                  items: paginatedChapters,
                  onTap: (index) {
                    controller.openReaderForChapter(controller.mangaChapters, index);
                  },
                )
              : BookListView(
                  items: paginatedChapters, 
                  onTap: (index) {
                    controller.openReaderForChapter(controller.mangaChapters, index);
                  },
                  isBook: false,
                ),
            ),
        ],
      );
    }

    //: Libros (Libros, Novelas Ligeras, Pdfs)
    if (tab == FranchiseMediaType.libros) {
      return BookListView(
        items: items, 
        onTap: (index) {
          controller.openReaderForChapter(controller.bookItems, index);
        },
        isBook: true,
      );
    }

    //: Video (anime, películas, etc.)
    if (tab == FranchiseMediaType.anime) {
      final episodes = controller.filteredAnimeEpisodes;
      return VideoListView(
        controller: controller.animeScrollController,
        episodes: episodes, 
        onEpisodeTap: (idx) {
          controller.openPlayerForEpisode(controller.filteredAnimeEpisodes, idx);
        },
      );
    }

    return const Center(
      child: Text('Vista de Resumen en Markdown', style: TextStyle(color: AppColors.textSecondary)),
    );
  }
}