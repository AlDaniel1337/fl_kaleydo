import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/home/controllers/home_controller.dart';
import 'package:kaleydo/app/modules/home/views/widgets/paginator/paginador.dart';
import 'package:kaleydo/app/modules/home/views/widgets/widgets.index.dart';

class HomeView extends GetView<HomeController> {

  static const String route = "/home";

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
    bindings: <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.f5): () {
        controller.scanLibrary();
      },
    },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [

              //: 1. Sidebar Fija
              const KaleydoSidebar(),
        
              //+ 2. Área Principal (Header + Contenido Grid + Footer)
              Expanded(
                child: Column(
                  children: [
                    
                    //: Header Superior
                    const KaleydoHeader(),
        
                    //: Sub-header (Título Dinámico y Filtro por Nombre)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          //: Título dinámico de la categoría seleccionada
                          Obx(() => DynamicCategoryTitle(
                            title: controller.selectedCategoryTitle.value,
                          )),
        
                          //: Desplegable de filtro rápido
                          const QuickFilterDropdown(),

                        ],
                      ),
                    ),
        
                    //: Grid de Contenido Principal
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: CatalogGrid(),
                      ),
                    ),
        
                    //: Paginación Inferior
                    _buildPaginator(),
                  ],
                ),
              ),
              //!+

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Obx(() {
        final current = controller.currentPage.value;
        final total = controller.totalPages.value;

        if ( controller.isRandomTabSelected ) return const SizedBox.shrink();

        return Paginador(
          current: current, 
          total: total, 
          onPageChanged: (page) => controller.changePage(page),
        );
      }),
    );
  }

}