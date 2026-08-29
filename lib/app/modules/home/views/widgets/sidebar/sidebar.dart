import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/controllers/home_controller.dart';
import 'package:kaleydo/app/modules/home/views/widgets/sidebar/components/custom_nav_item.dart';
import 'package:kaleydo/app/modules/home/views/widgets/sidebar/components/sidebar_title.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

/// Widget que representa la barra lateral de la aplicación Kaleydo. Contiene la lista de categorías dinámicas y la opción por defecto "Todo".
class KaleydoSidebar extends GetView<HomeController> {

  const KaleydoSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: AppColors.sidebarBackground,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          //: Título de la barra lateral
          const SidebarTitle(),
          
          //: Opción por defecto: Todo
          Obx(() => CustomNavItem(
            icon: Icons.border_all_rounded,
            label: 'Todo',
            rawCategory: 'all',
            isSelected: controller.selectedCategoryRaw.value == 'all',
            onTap: () => controller.selectCategory('all'),
          )),

          const CustomDivider(),

          //+ Lista dinámica basada en el contenido de la carpeta raíz
          Expanded(
            child: Obx(() {

              //: Mostrar mensaje si no hay carpetas disponibles
              if (controller.dynamicCategories.isEmpty) {
                return const NoFoldersMessage();
              }

              //: Construir la lista de elementos de navegación para cada categoría dinámica
              return ListView.builder(
                shrinkWrap: true,
                itemCount: controller.dynamicCategories.length,
                itemBuilder: (context, index) {
                  final cat = controller.dynamicCategories[index];
                  return Obx(() => CustomNavItem(
                    icon: cat.icon,
                    label: cat.displayName,
                    rawCategory: cat.rawFolderName,
                    isUnknown: !cat.isKnown,
                    isSelected: controller.selectedCategoryRaw.value == cat.rawFolderName,
                    onTap: () => controller.selectCategory(cat.rawFolderName),
                  ));
                },
              );
            }),
          ),
          //!+

        ],
      ),
    );
  }
  
}