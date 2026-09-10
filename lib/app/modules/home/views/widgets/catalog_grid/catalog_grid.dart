import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/views/franchise_detail_view.dart';
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
      
      // Indicador de escaneo en curso
      if (controller.isScanning.value) {
        return LoadingWidget();
      }

      // Mensaje cuando no hay elementos filtrados
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                const double minItemWidth = 160.0;
                const double maxItemWidth = 160.0;
                const double spacing = 18.0;
                const double paddingHorizontal = 16.0;

                final availableWidth = constraints.maxWidth - (paddingHorizontal * 2);

                int crossAxisCount = ((availableWidth + spacing) / (minItemWidth + spacing)).floor();
                if (crossAxisCount < 1) crossAxisCount = 1;

                double itemWidth = (availableWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;

                if (itemWidth > maxItemWidth) {
                  itemWidth = maxItemWidth;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12, 
                    horizontal: paddingHorizontal,
                  ),
                  // Align fuerza a que todo el contenido se pegue a la izquierda del scroll
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      alignment: WrapAlignment.start, // Alinea tarjetas a la izquierda de la fila
                      runAlignment: WrapAlignment.start, // Alinea filas hacia arriba
                      crossAxisAlignment: WrapCrossAlignment.start, // Alinea items en el eje vertical
                      children: displayItems.map((item) {
                        return SizedBox(
                          width: itemWidth,
                          child: AspectRatio(
                            aspectRatio: 0.60,
                            child: MediaCard(item: item),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isRandomMode)
            LoadRandomElementsBtn(onPressed: controller.loadRandomItems),
        ],
      );

    });
  }
}



/// Widget que representa una tarjeta individual de un elemento multimedia dentro del grid.
class MediaCard extends StatelessWidget {
  final MediaItemModel item;

  const MediaCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          //: Navega enviando el objeto con la ruta y datos del contenido seleccionado
          Get.toNamed(FranchiseDetailView.route, arguments: item);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              
              //: Imagen y texto de Portada dinámicamente cargada
              CoverImage(item: item),
        
              //: Badge de tipo de medio en la esquina superior izquierda
              Positioned(
                top: 8,
                left: 8,
                child: ContentTypeBadge(item: item),
              ),
            ],
          ),
        ),
      ),
    );
  }

}