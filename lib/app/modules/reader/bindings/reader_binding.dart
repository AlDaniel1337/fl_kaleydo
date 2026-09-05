import 'package:get/get.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';


/// Binding para la vista del lector
class ReaderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReaderController>(() => ReaderController());
  }
}