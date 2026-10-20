import 'package:flutter/material.dart';

/// Widget que muestra un icono y el porcentaje de volumen actual.
/// Cambia el icono y el color según si el volumen está apagado, normal o con boost.
class VolumeIconAndText extends StatelessWidget {

  final bool isBoosted;
  final bool isMuted;
  final double currentVolume;


  const VolumeIconAndText({
    super.key,
    required this.isBoosted,
    required this.isMuted,
    required this.currentVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        //: Icon que representa el estado del volumen (apagado, normal o con boost)
        Icon( isMuted
              ? Icons.volume_off 
              : isBoosted 
                  ? Icons.volume_up 
                  : Icons.volume_down,
          color: isBoosted ? Colors.orange : Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),

        //: Texto que muestra el porcentaje de volumen actual del volumen
        Text( '${currentVolume.toInt()}%',
          style: TextStyle(
            color: isBoosted ? Colors.orange : Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}