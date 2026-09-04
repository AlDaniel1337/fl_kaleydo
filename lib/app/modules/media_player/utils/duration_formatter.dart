/// Utilidad para formatear duraciones en un formato legible (HH:MM:SS).
abstract class DurationFormatter {
  static String format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours > 0 ? '${duration.inHours}:' : '';
    
    return '$hours$minutes:$seconds';
  }
}