import 'package:get/get.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/controllers/franchise_detail_controller.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/controllers/anime_tab_controller.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/controllers/game_tab_controller.dart';
import 'package:kaleydo/app/modules/franchise_detail/presentation/controllers/manga_tab_controller.dart';


/// Binding para la vista de detalle de franquicia
class FranchiseDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FranchiseDetailController>(() => FranchiseDetailController());
    Get.lazyPut<AnimeTabController>(() => AnimeTabController(), fenix: true);
    Get.lazyPut<MangaTabController>(() => MangaTabController(), fenix: true);
    Get.lazyPut<GameTabController>(()  => GameTabController(),  fenix: true);
  }
}