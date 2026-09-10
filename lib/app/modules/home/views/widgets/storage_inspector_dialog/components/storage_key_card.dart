import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'storage_item_tile.dart';

class StorageKeyCard extends StatelessWidget {
  final String keyName;
  final dynamic value;
  final VoidCallback onRemoveKey;
  final Function(int) onRemoveListItem;
  final Function(dynamic) onRemoveMapKey;

  const StorageKeyCard({
    required this.keyName,
    required this.value,
    required this.onRemoveKey,
    required this.onRemoveListItem,
    required this.onRemoveMapKey,
  });

  @override
  Widget build(BuildContext context) {
    final bool isList = value is List;
    final bool isMap = value is Map;
    final bool hasMultipleItems =
        (isList && (value as List).isNotEmpty) || (isMap && (value as Map).isNotEmpty);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, right: 32),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          //: CABECERA
          // Nombre de la clave y botón de eliminación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                keyName,
                style: const TextStyle(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'Eliminar toda la clave',
                onPressed: onRemoveKey,
              ),
            ],
          ),
          const SizedBox(height: 4),

          //: MULTIPLES ELEMENTOS
          // Muestra los elementos individuales si hay múltiples elementos guardados
          if (hasMultipleItems) ...[

            const Text(
              'Elementos guardados (elimina de forma individual):',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 6),

            Container(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: isList ? (value as List).length : (value as Map).keys.length,
                itemBuilder: (context, subIndex) {
                  if (isList) {
                    final item = (value as List)[subIndex];
                    return StorageItemTile(
                      displayText: '$item',
                      onDelete: () => onRemoveListItem(subIndex),
                    );
                  } else {
                    final mapKey = (value as Map).keys.elementAt(subIndex);
                    final mapVal = value[mapKey];
                    return StorageItemTile(
                      displayText: '$mapKey ➔ $mapVal',
                      onDelete: () => onRemoveMapKey(mapKey),
                    );
                  }
                },
              ),
            ),
          ]
          
          //: VALOR ÚNICO
          // Muestra el valor directamente si no hay múltiples elementos guardados.
          else ...[
            Text(
              '$value',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}