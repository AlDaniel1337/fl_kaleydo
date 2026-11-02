import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/views/franchise_detail_view.dart';
import 'package:kaleydo/app/modules/home/controllers/home_controller.dart';
import 'package:kaleydo/app/modules/home/views/widgets/catalog_grid/components/content_type_badge.dart';
import 'package:kaleydo/app/modules/home/views/widgets/catalog_grid/components/cover_image.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

/// Widget que muestra un grid de elementos multimedia filtrados y paginados.
class CatalogGrid extends GetView<HomeController> {
  const CatalogGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      
      // Indicador de escaneo en curso
      if (controller.isScanning.value) {
        return const LoadingWidget();
      }

      // Mensaje cuando no hay elementos filtrados
      if (controller.filteredMediaItems.isEmpty) {
        return const NoMultimediaMessage();
      }

      final isRandomMode = controller.selectedTab.value == ViewTab.random;
      final displayItems = isRandomMode
          ? controller.randomMediaItems.toList()
          : controller.paginatedItems.toList();

      //: Construir el GridView con los elementos paginados
      return Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              // El delegate ajusta automáticamente las columnas y el tamaño
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180.0, // Ancho máximo que intentará tener cada tarjeta
                mainAxisSpacing: 12.0,     // Espaciado vertical entre tarjetas
                crossAxisSpacing: 12.0,    // Espaciado horizontal entre tarjetas
                childAspectRatio: 0.63,    // Proporción ancho/alto (ajusta el alto dinámicamente)
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                return MediaCard(item: displayItems[index]);
              },
            ),
          ),
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
            fit: StackFit.expand, // Asegura que el contenido llene toda la tarjeta
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