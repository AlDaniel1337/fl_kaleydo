import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

mixin PlayerSubtitleMixin on GetxController {
  Player get player;
  void showOSD(String text);
  void saveAllSettings();

  // Estados de subtítulos
  final RxList<SubtitleTrack> availableSubtitles = <SubtitleTrack>[].obs;
  final Rx<SubtitleTrack> currentSubtitle = SubtitleTrack.no().obs;
  SubtitleTrack lastSelectedSubtitle = SubtitleTrack.no();
  final RxBool subtitlesEnabled = false.obs;

  //+ Subtítulos del reproductor
  /// Establece la pista de subtítulos activa.
  void setSubtitleTrack(SubtitleTrack track) {
    if (track != SubtitleTrack.no()) {
      lastSelectedSubtitle = track;
    }
    player.setSubtitleTrack(track);
  }

  /// Alterna entre activar y desactivar los subtítulos.
  void toggleSubtitles() {
    final validSubtitles = availableSubtitles.where((t) => t != SubtitleTrack.no()).toList();

    if (validSubtitles.isEmpty) {
      showOSD('Sin subtítulos disponibles');
      return;
    }

    final bool isOff = currentSubtitle.value == SubtitleTrack.no();

    if (isOff) {
      final SubtitleTrack trackToSelect = (validSubtitles.any((t) => t.id == lastSelectedSubtitle.id))
          ? lastSelectedSubtitle
          : validSubtitles.first;

      setSubtitleTrack(trackToSelect);
      subtitlesEnabled.value = true;

      final String label = trackToSelect.title ?? trackToSelect.language ?? 'Activados';
      showOSD('Subtítulos: $label');
    } else {
      lastSelectedSubtitle = currentSubtitle.value;
      player.setSubtitleTrack(SubtitleTrack.no());
      subtitlesEnabled.value = false;
      showOSD('Subtítulos: Desactivados');
    }

    saveAllSettings();
  }
  //!+
}