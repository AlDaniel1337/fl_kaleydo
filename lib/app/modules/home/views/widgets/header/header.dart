import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/home/views/widgets/header/components/tab_button.dart';
import 'package:kaleydo/app/modules/home/views/widgets/storage_inspector_dialog/storage_inspector_dialog.dart';
import 'components/header_title.dart';
import 'components/global_search_bar.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/controllers/home_controller.dart';
import 'package:kaleydo/app/modules/settings/controllers/config_controller.dart';

/// Widget que representa el encabezado de la aplicación Kaleydo. Contiene el título, el selector de pestañas, la barra de búsqueda y los botones de acción.
class KaleydoHeader extends GetView<HomeController> {
  const KaleydoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final configController = Get.find<ConfigController>();

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [

          //: Título Logo
          const HeaderTitle(),
          const SizedBox(width: 40),

          //: Selector de Pestañas (Todo / Favoritos / Aleatorio)
          Obx(() => Row(
            children: [
              _buildTabButton('Todo', ViewTab.todo),
              const SizedBox(width: 20),
              _buildTabButton('En Proceso', ViewTab.inProcess),
              const SizedBox(width: 20),
              _buildTabButton('Favoritos', ViewTab.favoritos),
              const SizedBox(width: 20),
              _buildTabButton('Aleatorio', ViewTab.random),
            ],
          )),

          const Spacer(),

          //: Barra de Búsqueda Global
          GlobalSearchBar(
            onChanged: (val) => controller.searchQuery.value = val,
          ),
          const SizedBox(width: 16),

          //: Botón: Cargar de nuevo (Refresh)
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: AppColors.textSecondary),
            tooltip: 'Cargar de nuevo',
            onPressed: controller.scanLibrary,
          ),

          //: Botón Abrir Carpeta Raíz
          IconButton(
            icon: const Icon(Icons.folder_open_rounded, color: AppColors.textSecondary),
            tooltip: 'Abrir Carpeta Raíz',
            onPressed: configController.selectRootDirectory,
          ),

          //: Ajustes
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            tooltip: 'Configuración',
            onPressed: () {},
          ),

          IconButton(
            icon: const Icon(Icons.storage_rounded, color: Colors.white70),
            tooltip: 'Gestionar Almacenamiento',
            onPressed: () => showStorageInspectorModal(context),
          ),
        ],
      ),
    );
  }



  ///: Construye un botón de pestaña para el encabezado.
  Widget _buildTabButton(String label, ViewTab tab) {
    final isSelected = controller.selectedTab.value == tab;
    return TabButton(
      label: label, 
      isSelected: isSelected, 
      onTap: () => controller.selectTab(tab)
    );
  }
}