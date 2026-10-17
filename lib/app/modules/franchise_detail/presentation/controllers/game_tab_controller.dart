import 'package:get/get.dart';
import 'package:kaleydo/app/data/data.models.index.dart';
import 'package:kaleydo/app/modules/franchise_detail/data/services/game_extra_info_service.dart';
import 'package:process_run/shell.dart';

class GameTabController extends GetxController {

  final GameExtraInfoService _extraInfoService = GameExtraInfoService();

  FranchiseItemModel? selectedGameItem;
  final RxString selectedGameItemInfo = ''.obs;
  final RxList<String> selectedGameItemTags = <String>[].obs;
  final RxBool hasCGsGallery = false.obs;
  final RxList<String> selectedGameItemImages = <String>[].obs;
  final RxList<String> randomSelectedGameItemImages = <String>[].obs;
  final RxInt selectedGameItemIndex = 0.obs;


  /// Establece el elemento de juego seleccionado y carga su información adicional.
  Future<void> setSelectedGameItem(FranchiseItemModel? item, int index) async {
   
    _clearSelectedGameItem();
    selectedGameItem = item;

    if (item == null) return;

    selectedGameItemIndex.value = index;
    final result = await _extraInfoService.loadExtraData(item.path);

    selectedGameItemInfo.value = result.info;
    selectedGameItemTags.assignAll(result.tags);
    selectedGameItemImages.assignAll(result.images);
    randomSelectedGameItemImages.assignAll(result.randomImages);
    hasCGsGallery.value = result.hasCGsGallery;
  }


  /// Lanza el ejecutable del juego especificado por la ruta proporcionada. 
  /// - Muestra un mensaje de error si no se puede iniciar el programa.
  Future<void> launchExecutable(String path) async {
    try {
      final shell = Shell();
      await shell.run('"$path"');
    } catch (e) {
      Get.snackbar('Error al ejecutar', 'No se pudo iniciar el programa: $e');
    }
  }


  /// Limpia la información del elemento de juego seleccionado.
  void _clearSelectedGameItem() {
    selectedGameItem = null;
    selectedGameItemInfo.value = '';
    hasCGsGallery.value = false;

    selectedGameItemTags.clear();
    selectedGameItemImages.clear();
    randomSelectedGameItemImages.clear();
  }
}