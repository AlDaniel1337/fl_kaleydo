import 'package:flutter/material.dart';

class FullScreenButton extends StatelessWidget {

  final bool isFullScreen;
  final VoidCallback toggleFullScreen;
   
  const FullScreenButton({
    super.key,
    required this.isFullScreen,
    required this.toggleFullScreen,
  });
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon( isFullScreen
          ? Icons.fullscreen_exit_rounded
          : Icons.fullscreen_rounded,
        color: Colors.white,
      ),
      onPressed: toggleFullScreen,
    );
  }
}