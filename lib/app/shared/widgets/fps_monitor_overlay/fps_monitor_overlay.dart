import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

/// Overlay que muestra las estadísticas de FPS del video y la tasa de refresco del monitor.
class FpsMonitorOverlay extends StatefulWidget {

  final Player player;
  
  const FpsMonitorOverlay({
    super.key, 
    required this.player
  });

  @override
  State<FpsMonitorOverlay> createState() => _FpsMonitorOverlayState();
}



class _FpsMonitorOverlayState extends State<FpsMonitorOverlay> {
  Timer? _timer;
  String _videoFps = "--";
  String _displayHz = "--";

  @override
  void initState() {
    super.initState();
    // Consulta las estadísticas cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _fetchStats());
  }

  /// Obtiene la tasa de refresco del monitor en Hz como un string con un decimal.
  String getDiviceHz() => View.of(context).display.refreshRate.toStringAsFixed(1);


  /// Obtiene las estadísticas de FPS del video y del monitor, y actualiza el estado del widget.
  Future<void> _fetchStats() async {
    final platform = widget.player.platform;

    if (platform is NativePlayer) {
      // estimated-vf-fps: FPS reales renderizados por el filtro de video
      final videoFps = await platform.getProperty('estimated-vf-fps');
      // display-fps: Tasa de refresco detectada de la pantalla
      _displayHz = getDiviceHz();
      
      if (mounted) {
        setState(() {
          _videoFps  = double.tryParse(videoFps)?.toStringAsFixed(1)  ?? "--";
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        'Video: $_videoFps FPS\nMonitor: $_displayHz Hz',
        style: const TextStyle(
          color: Colors.white, 
          fontFamily: 'Consolas', // Tipografía monoespaciada para evitar saltos
          fontSize: 12,
        ),
      ),
    );
  }
}