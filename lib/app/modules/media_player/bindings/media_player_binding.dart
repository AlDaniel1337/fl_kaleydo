import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';

/// Binding para el módulo de Media Player.
/// Se encarga de inyectar las dependencias necesarias para el módulo de Media Player.
class MediaPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaPlayerController>(() => MediaPlayerController());
  }
}