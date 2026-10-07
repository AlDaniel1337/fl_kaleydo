import 'package:flutter/material.dart';

class GoBackBtn extends StatelessWidget {

  final VoidCallback? onPressed;
   
  const GoBackBtn({super.key, this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.arrow_back, 
        color: Colors.white
      ),
      onPressed: onPressed,
    );
  }
}