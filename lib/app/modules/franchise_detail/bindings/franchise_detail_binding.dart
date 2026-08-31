import 'package:get/get.dart';
import 'package:kaleydo/app/modules/franchise_detail/controllers/franchise_detail_controller.dart';


/// Binding para la vista de detalle de franquicia
class FranchiseDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FranchiseDetailController>(() => FranchiseDetailController());
  }
}