import 'package:flutter/material.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'settings_menu_dialog.dart';

PopupMenuItem<dynamic> goBackMenuItem({
  required BuildContext context,
  required MediaPlayerController controller,
  required String title,
}) {
  return PopupMenuItem(
    enabled: false,
    child: SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          //: Encabezado 
          // Botón de retroceso y título
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.pop(context);
                  showSettingsMenu(context, controller);
                },
              ),

              SizedBox(width: 8),

              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ]
      ),
    ),
  );
}
