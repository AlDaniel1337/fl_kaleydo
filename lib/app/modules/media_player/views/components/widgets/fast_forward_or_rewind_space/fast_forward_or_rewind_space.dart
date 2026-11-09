import 'package:flutter/material.dart';

/// Widget que muestra un espacio para adelantar o retroceder el video.
class FastForwardOrRewindSpace extends StatefulWidget {
  final bool isOnRight;
  final VoidCallback onTap;
  final double heightFactor;
  final bool showIcon;
  final bool shouldShowCursor;

  const FastForwardOrRewindSpace({
    super.key,
    required this.isOnRight,
    required this.onTap,
    this.heightFactor = 0.75,
    this.showIcon = true,
    this.shouldShowCursor = false,
  });

  @override
  State<FastForwardOrRewindSpace> createState() => _FastForwardOrRewindSpaceState();
}



class _FastForwardOrRewindSpaceState extends State<FastForwardOrRewindSpace> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width * 0.12;

    return SizedBox(
      width: width,
      height: MediaQuery.of(context).size.height * widget.heightFactor,
      child: Material(
        color: Colors.transparent,
        
        child: InkWell(
          onTap: widget.onTap,
          mouseCursor: widget.shouldShowCursor 
           ? SystemMouseCursors.basic 
           : SystemMouseCursors.none,
      
          onHover: (isHovering) {
            setState(() {
              _isHovered = isHovering;
            });
          },
      
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isHovered ? 1.0 : 0.0,
              child: widget.showIcon ? Icon(
                widget.isOnRight 
                    ? Icons.forward_10 
                    : Icons.replay_10,
                size: 40,
                color: Colors.white,
              ) : const SizedBox.shrink(),
            ),
          ),
        
        ),
      ),
    );
  }
}