import 'package:flutter/material.dart';

/// Widget que representa una opción de configuración con un ícono, un título y un widget final opcional.
/// 
/// [icon] es el ícono que se mostrará al inicio de la opción.
/// [title] es el texto que describe la opción.
/// [trailing] es el widget que se mostrará al final de la opción.
/// [onTap] es la función que se ejecutará al tocar la opción.
/// [showArrow] indica si se debe mostrar la flecha al final de la opción.

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final bool showArrow;
  final double width;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.showArrow = true,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: onTap,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
        
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
        
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 12),
        
              if (trailing != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailing,
                ),
              ),
        
              if (trailing == null) 
                const Spacer(),
              
              if (showArrow) ...[
                const SizedBox(width: 8),
                const Icon(Icons.arrow_right_rounded, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}