import 'dart:io';

import 'package:flutter/material.dart';
import './small_text_container.dart';

class GridImageItem extends StatelessWidget {
  const GridImageItem({
    super.key,
    required this.pageNum,
    required this.isCurrent,
    required this.imagePath,
  });

  final String imagePath;
  final int pageNum;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        
        //: Imagen de la página
        Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          cacheWidth: 400,
        ),
    
        //: Número de página
        Positioned(
          bottom: 4,
          right: 4,
          child: SmallTextContainer(
            pageNum: pageNum, 
            isCurrent: isCurrent
          ),
        ),
      ],
    );
  }
}