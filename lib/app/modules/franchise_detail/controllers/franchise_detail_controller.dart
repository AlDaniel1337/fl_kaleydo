import 'dart:io';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';
import 'package:kaleydo/app/data/services/franchise_scanner_service/franchise_scanner_service.dart';
import 'package:process_run/shell.dart';



/// Controlador para gestionar el detalle y la navegación de contenidos de una franquicia.
class FranchiseDetailController extends GetxController {
  final FranchiseScannerService _scannerService = FranchiseScannerService();

  //+ VARIABLES DE ESTADO
  late final MediaItemModel mediaItem;

  //: Pestañas disponibles basadas en los tipos de medios encontrados físicamente.
  final RxList<FranchiseMediaType> availableTabs = <FranchiseMediaType>[].obs;
  final Rx<FranchiseMediaType> selectedTab = FranchiseMediaType.juegos.obs;

  //: Mapa general de contenidos indexados por tipo de medio.
  final RxMap<FranchiseMediaType, List<FranchiseItemModel>> mediaContent =
      <FranchiseMediaType, List<FranchiseItemModel>>{}.obs;

  //: Filtro de Temporadas para contenido tipo Anime.
  final RxList<String> animeSeasons = <String>['Completo'].obs;
  final RxString selectedAnimeSeason = 'Completo'.obs;

  final RxBool isLoading = true.obs;
  //!+



  @override
  void onInit() {
    super.onInit();
    _initializeArguments();
  }

  //+ CARGA DE DATOS
  /// Carga y clasifica los detalles de la franquicia desde el sistema de archivos.
  Future<void> loadFranchiseDetails() async {
    isLoading.value = true;

    //: Intento de cargar los detalles de la franquicia desde el sistema de archivos.
    try {
      final franchiseDir = Directory(mediaItem.path);
      if (!await franchiseDir.exists()) return;

      final scannedContent = await _scannerService.scanFranchiseDirectory(
        franchiseDir,
        mediaItem.coverPath ?? '',
      );

      _updateMediaState(scannedContent);
    } catch (e) {
      Get.snackbar('Error de lectura', 'No se pudieron cargar los datos de la franquicia: $e');
    } finally {
      isLoading.value = false;
    }
  }



  /// Ejecuta una aplicación o juego a partir de su ruta física.
  Future<void> launchExecutable(String path) async {
    try {
      final shell = Shell();
      await shell.run('"$path"');
    } catch (e) {
      Get.snackbar('Error al ejecutar', 'No se pudo iniciar el programa: $e');
    }
  }
  //!+



  //+ GETTERS
  /// Retorna los episodios de Anime filtrados por la temporada seleccionada.
  List<FranchiseItemModel> get filteredAnimeEpisodes {
    final allEpisodes = mediaContent[FranchiseMediaType.anime] ?? [];
    if (selectedAnimeSeason.value == 'Completo') return allEpisodes;

    return allEpisodes.where((ep) => ep.seasonName == selectedAnimeSeason.value).toList();
  }
  //!+



  //+ MÉTODOS PRIVADOS AUXILIARES
  /// Valida e inicializa los argumentos pasados por GetX.
  void _initializeArguments() {
    if (Get.arguments is MediaItemModel) {
      mediaItem = Get.arguments as MediaItemModel;
      loadFranchiseDetails();
    }
  }

  /// Actualiza los reactivos de medios, pestañas y temporadas.
  void _updateMediaState(Map<FranchiseMediaType, List<FranchiseItemModel>> scannedContent) {
    mediaContent.assignAll(scannedContent);

    final tabs = scannedContent.keys.toList();
    availableTabs.assignAll(tabs);

    if (tabs.isNotEmpty) {
      selectedTab.value = tabs.first;
    }

    _setupAnimeSeasons(scannedContent[FranchiseMediaType.anime]);
  }



  /// Extrae y actualiza las temporadas únicas disponibles para el anime.
  void _setupAnimeSeasons(List<FranchiseItemModel>? animeEpisodes) {
    if (animeEpisodes == null || animeEpisodes.isEmpty) {
      animeSeasons.assignAll(['Completo']);
      selectedAnimeSeason.value = 'Completo';
      return;
    }

    final seasons = animeEpisodes
      .map((ep) => ep.seasonName)
      .whereType<String>()
      .toSet();

    animeSeasons.assignAll(['Completo', ...seasons]);
    selectedAnimeSeason.value = 'Completo';
  }
  //!+
}