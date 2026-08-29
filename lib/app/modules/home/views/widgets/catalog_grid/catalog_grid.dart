import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'package:kaleydo/app/modules/home/controllers/home_controller.dart';
import 'package:kaleydo/app/modules/home/views/widgets/catalog_grid/components/content_type_badge.dart';
import 'package:kaleydo/app/modules/home/views/widgets/catalog_grid/components/cover_image.dart';
import 'package:kaleydo/app/modules/home/views/widgets/catalog_grid/components/load_random_elements_btn.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';



/// Widget que muestra un grid de elementos multimedia filtrados y paginados.
class CatalogGrid extends GetView<HomeController> {
  const CatalogGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (controller.isScanning.value) {
        return LoadingWidget();
      }

      if (controller.filteredMediaItems.isEmpty) {
        return const NoMultimediaMessage();
      }

      final isRandomMode = controller.selectedTab.value == ViewTab.random;
      final displayItems = isRandomMode
          ? controller.randomMediaItems
          : controller.paginatedItems;

      //: Construir el GridView con los elementos paginados
      return Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.72,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return MediaCard(item: item);
              },
            ),
          ),

          // Botón para recargar aleatorios cuando se está en el modo Random
          if (isRandomMode)
          LoadRandomElementsBtn(onPressed: controller.loadRandomItems),
        ],
      );
    });
  }
}

class MediaCard extends StatelessWidget {
  final MediaItemModel item;

  const MediaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          
          // Imagen de Portada dinámicamente cargada
          CoverImage(item: item),

          // Badge de tipo de medio en la esquina superior izquierda
          Positioned(
            top: 8,
            left: 8,
            child: ContentTypeBadge(item: item),
          ),
        ],
      ),
    );
  }

}