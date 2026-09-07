import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';

class ReaderScrollView extends StatelessWidget {
  
  final ReaderController controller;

  const ReaderScrollView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 60),
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemCount: controller.imagePaths.length,
      itemBuilder: (context, index) {
        return Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Image.file(
              File(controller.imagePaths[index]),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              cacheWidth: 1200,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return Container(
                  height: 900,
                  color: AppColors.cardBackground.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryAccent,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}