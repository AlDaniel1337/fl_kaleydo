import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';

class MediaPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaPlayerController>(() => MediaPlayerController());
  }
}