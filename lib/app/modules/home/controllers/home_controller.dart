import 'dart:io';

import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_media_type.dart';
import 'package:kaleydo/app/core/utils/capitalize_text.dart';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'package:kaleydo/app/data/models/sidebar_category_model.dart';
import 'package:kaleydo/app/data/providers/scanner_provider.dart';
import 'package:kaleydo/app/modules/settings/controllers/config_controller.dart';
import 'package:path/path.dart' as p;



/// Pestañas de vista disponibles en la interfaz principal.
enum ViewTab { todo, favoritos, random }



/// Controlador principal de la pantalla de inicio, que maneja la lógica de filtrado, paginación y escaneo de la biblioteca de medios.
class HomeController extends GetxController {

  //+ Variables, dependencias y controladores.
  //: Proveedores y controladores necesarios para el escaneo y la configuración.
  final ScannerProvider _scannerProvider = ScannerProvider();
  final ConfigController _configController = Get.find<ConfigController>();

  //: Estados reactivos de carga y listas
  final RxBool isScanning = false.obs;
  final RxList<MediaItemModel> allMediaItems = <MediaItemModel>[].obs;
  final RxList<MediaItemModel> filteredMediaItems = <MediaItemModel>[].obs;

  // Categorías detectadas dinámicamente en el Sidebar
  final RxList<SidebarCategoryModel> dynamicCategories = <SidebarCategoryModel>[].obs;
  final RxString selectedCategoryRaw = 'all'.obs; // 'all' representa la opción "Todo"
  final RxString selectedCategoryTitle = 'Todo'.obs; // 'all' representa la opción "Todo"

  //: Filtros de navegación
  final Rx<ViewTab> selectedTab = ViewTab.todo.obs;
  final RxString searchQuery = ''.obs;

  //: Paginación
  final RxInt currentPage = 1.obs;
  final int itemsPerPage = 12;
  final RxInt totalPages = 1.obs;

  // Lista específica para los elementos en modo aleatorio
  final RxList<MediaItemModel> randomMediaItems = <MediaItemModel>[].obs;
  //!+



  ///+ [Inicialización] - Métodos de inicialización y escaneo de la biblioteca.
  @override
  void onInit() {
    super.onInit();
    //: Escuchar cambios en la búsqueda o categorías para re-filtrar
    ever(selectedCategoryRaw, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
    ever(_configController.config, (_) => scanLibrary());
    ever(selectedTab, (_) {
      if (selectedTab.value == ViewTab.random) {
        loadRandomItems();
      } else {
        applyFilters();
      }
    });

    scanLibrary();
  }
  //!+




  ///+ [Escaneo] - Escaneo de la carpeta raíz
  Future<void> scanLibrary() async {
    final rootPath = _configController.rootPath;
    if (rootPath.isEmpty) return;

    //: Verificar si la ruta raíz está configurada antes de escanear.
    try {
      isScanning.value = true;

      //: 1. Escanear carpetas del Sidebar
      await _detectSidebarCategories(rootPath);

      //: 2. Escanear contenidos multimedia
      final items = await _scannerProvider.scanRootFolder(_configController.config.value);
      allMediaItems.assignAll(items);
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error de Escaneo',
        'No se pudieron cargar los archivos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isScanning.value = false;
    }
  }
  //!+



  ///+ [Random Items] Generar / Reordenar 10 elementos aleatorios respetando la categoría actual
  void loadRandomItems() {
    List<MediaItemModel> sourceList = List.from(allMediaItems);

    //: Si hay una categoría seleccionada en el sidebar (diferente a 'all'), filtramos primero
    if (selectedCategoryRaw.value != 'all') {
      sourceList = sourceList.where((item) {
        return p.basename(p.dirname(item.path)) == selectedCategoryRaw.value;
      }).toList();
    }

    //: Mezclar la lista
    sourceList.shuffle();

    //: Tomar máximo 10 elementos
    final count = sourceList.length < 10 ? sourceList.length : 10;
    randomMediaItems.assignAll(sourceList.take(count).toList());
  }
  //!+



  ///+ [Filtros] - Aplica los filtros de Categoría, Búsqueda y Favoritos
  void applyFilters() {
    if (selectedTab.value == ViewTab.random) {
      loadRandomItems();
      return;
    }

    List<MediaItemModel> temp = List.from(allMediaItems);

    //: 1. Filtro por Pestaña, mostrar solo los elementos correspondientes a la pestaña seleccionada.
    if (selectedTab.value == ViewTab.favoritos) {
      temp = temp.where((item) => item.isFavorite).toList();
    }

    //: 2. Filtro por Categoría Seleccionada en Sidebar, mostrar solo los elementos que pertenecen a la categoría seleccionada.
    if (selectedCategoryRaw.value != 'all') {
      temp = temp.where((item) {
        // Coincidencia con la ruta de la carpeta uni-medio
        return p.basename(p.dirname(item.path)) == selectedCategoryRaw.value;
      }).toList();
    }

    //: 3. Actualizar el título de la categoría seleccionada, eliminando "_" del nombre raw
    selectedCategoryTitle.value = selectedCategoryRaw.value == 'all'
      ? 'Mostrar todo'
      : capitalizeText(selectedCategoryRaw.value.replaceAll('_', ''));

    //: 4. Filtro por Búsqueda, mostrar solo los elementos cuyo título contiene la consulta de búsqueda.
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      temp = temp.where((item) => item.title.toLowerCase().contains(query)).toList();
    }

    //: 5. Actualizar la lista filtrada y la paginación.
    filteredMediaItems.assignAll(temp);
    totalPages.value = (filteredMediaItems.length / itemsPerPage).ceil();
    if (totalPages.value == 0) totalPages.value = 1;
    currentPage.value = 1;
  }
  //!+



  ///+ [Paginación] - Obtener los elementos de la página actual
  List<MediaItemModel> get paginatedItems {
    final startIndex = (currentPage.value - 1) * itemsPerPage;
    if (startIndex >= filteredMediaItems.length) return [];

    final endIndex = startIndex + itemsPerPage;
    return filteredMediaItems.sublist(
      startIndex,
      endIndex > filteredMediaItems.length ? filteredMediaItems.length : endIndex,
    );
  }
  //!+



  ///+ [Paginación] - Cambiar de página
  void changePage(int page) {
    if (page >= 1 && page <= totalPages.value) {
      currentPage.value = page;
    }
  }
  //!+



  /// [Sidebar] - Seleccionar categoría
  void selectCategory(String rawCategoryName) => selectedCategoryRaw.value = rawCategoryName;




  /// [Sidebar] - Seleccionar pestaña
  void selectTab(ViewTab tab) => selectedTab.value = tab;




  ///+ [Sidebar] - Detectar categorías dinámicas en el sistema de archivos
  Future<void> _detectSidebarCategories(String rootPath) async {
    //: Verificar que el directorio raíz exista antes de continuar.
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return;

    final List<SidebarCategoryModel> detected = [];
    final List<FileSystemEntity> entities = await rootDir.list().toList();

    //: Listar todas las entidades dentro del directorio raíz y procesar solo las carpetas que inician con "_".
    for (var entity in entities) {
      if (entity is Directory) {
        final folderName = p.basename(entity.path);
        
        //: Solo procesar carpetas que inician con "_"
        if (folderName.startsWith('_')) {
          final cleanName = folderName.substring(1).toLowerCase();

          final icon = AppMediaType.values.firstWhere(
            (e){ 

              // Volver a lowercase ambos
              final entityNameLower = e.name.toLowerCase();
              final cleanNameLower = cleanName.toLowerCase();

              // Eliminar espacios en blanco de ambos
              final entityNameClean = entityNameLower.replaceAll(' ', '');
              final cleanNameClean = cleanNameLower.replaceAll(' ', '');
              
              return entityNameClean == cleanNameClean;
            },
            orElse: () => AppMediaType.unknownCategoryIcon,
          );

          //: Formatear nombre: elimina "_" y capitaliza
          final displayName = capitalizeText(folderName.substring(1));

          detected.add(SidebarCategoryModel(
            rawFolderName: folderName,
            displayName: displayName,
            icon: icon.icon,
            isKnown: icon != AppMediaType.unknownCategoryIcon,
          ));
        }
      }
    }

    //: Ordenar categorías alfabéticamente
    detected.sort((a, b) => naturalSortCompare(a.displayName, b.displayName));
    dynamicCategories.assignAll(detected);
  }
  //!+
}