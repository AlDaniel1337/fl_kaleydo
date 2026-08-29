import 'package:get/get.dart';
import 'package:kaleydo/app/modules/home/controllers/home_controller.dart';
import 'package:kaleydo/app/modules/settings/controllers/config_controller.dart';



/// Clase que define las dependencias para el módulo Home.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfigController>(() => ConfigController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}