import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';

class ReaderPageView extends StatelessWidget {
  
  final ReaderController controller;

  const ReaderPageView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.imagePaths.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: Center(
            child: Image.file(
              File(controller.imagePaths[index]),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
    );
  }
}