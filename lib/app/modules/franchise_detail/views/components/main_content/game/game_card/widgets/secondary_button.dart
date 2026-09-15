import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {

  final void Function()? onPressed;
  final String label;

  const SecondaryButton({
    super.key, 
    this.onPressed, 
    required this.label
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white54),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.black.withValues(alpha: 0.6),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}