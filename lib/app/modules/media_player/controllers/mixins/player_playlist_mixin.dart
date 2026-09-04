import 'dart:async';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/data/services/local_storage_service.dart';
import 'package:media_kit/media_kit.dart';


/// Mixin que proporciona funcionalidades relacionadas con la gestión de la playlist del reproductor.
mixin PlayerPlaylistMixin on GetxController {

  //: Referencias necesarias
  // Contratos requeridos del Controller principal
  Player get player;
  PlayerStorageService get storage;
  Rx<Duration> get duration;
  void showOSD(String message);

  //: Variables
  // Estados reactivos de la Playlist
  List<FranchiseItemModel> playlist = [];
  int currentIndex = 0;
  final RxBool showNextEpisodeBanner = false.obs;
  final RxBool showPreviousEpisodeBanner = false.obs;
  final RxInt autoPlayCountdown = 10.obs;
  Timer? autoPlayTimer;



  //+ Autoplay
  /// Inicia la cuenta regresiva para el siguiente episodio
  void startAutoPlayCountdown() {
    showNextEpisodeBanner.value = true;
    autoPlayCountdown.value = 10;
    autoPlayTimer?.cancel();

    autoPlayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (autoPlayCountdown.value > 1) {
        autoPlayCountdown.value--;
      } else {
        timer.cancel();
        playNextEpisode();
      }
    });
  }
  


  /// Verifica si se debe lanzar el banner/conteo del siguiente episodio
  void checkAutoPlayTrigger(Duration currentPos) {
    if (duration.value == Duration.zero) return;

    final remaining = (duration.value - currentPos).inSeconds;
    final hasNext = currentIndex + 1 < playlist.length;

    if (hasNext && remaining <= 10 && remaining > 0 && !showNextEpisodeBanner.value) {
      startAutoPlayCountdown();
    }
  }



  /// Cancela temporizadores al destruir
  void cancelPlaylistTimers() {
    autoPlayTimer?.cancel();
    showNextEpisodeBanner.value = false;
    showPreviousEpisodeBanner.value = false;
  }
  //!+



  //+ Cambiar episodio (Next/Previous)
  /// Reproduce el siguiente episodio en la playlist
  void playNextEpisode() {
    autoPlayTimer?.cancel();
    showNextEpisodeBanner.value = false;

    if (currentIndex + 1 < playlist.length) {
      currentIndex++;
      final nextEp = playlist[currentIndex];

      final savedMs = storage.getPosition(nextEp.path);
      final startPos = (storage.autoResumeEnabled && savedMs > 0)
          ? Duration(milliseconds: savedMs)
          : Duration.zero;

      player.open(Media(nextEp.path, start: startPos));
      showOSD('Reproduciendo: ${nextEp.title}');
    }
  }



  /// Reproduce el episodio anterior en la playlist
  void playPreviousEpisode() {
    autoPlayTimer?.cancel();
    showPreviousEpisodeBanner.value = false;

    if (currentIndex - 1 >= 0) {
      currentIndex--;
      final prevEp = playlist[currentIndex];

      final savedMs = storage.getPosition(prevEp.path);
      final startPos = (storage.autoResumeEnabled && savedMs > 0)
          ? Duration(milliseconds: savedMs)
          : Duration.zero;

      player.open(Media(prevEp.path, start: startPos));
      showOSD('Reproduciendo: ${prevEp.title}');
    }
  }
  //!+
}