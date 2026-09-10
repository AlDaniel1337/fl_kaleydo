import 'package:flutter/material.dart';

class CompactView extends StatelessWidget {

  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;
  final String? currentPageIndicator;
  final VoidCallback? onScrollToTop;
  
  const CompactView({
    super.key,
    this.onPreviousChapter,
    this.onNextChapter,
    this.currentPageIndicator,
    this.onScrollToTop,
  });
     
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          tooltip: 'Cap. anterior',
          onPressed: onPreviousChapter,
        ),
        const Spacer(),
        Text(
          currentPageIndicator ?? '0 / 0',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.white),
          tooltip: 'Cap. siguiente',
          onPressed: onNextChapter,
        ),
      ],
    );
      
  } 
}