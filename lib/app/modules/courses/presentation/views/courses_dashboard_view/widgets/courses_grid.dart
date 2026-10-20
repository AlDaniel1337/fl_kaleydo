import 'package:flutter/material.dart';

class CoursesGrid extends StatelessWidget {

  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
   
  const CoursesGrid({
    super.key, 
    required this.itemBuilder, 
    required this.itemCount,
    this.crossAxisCount = 4,
    this.childAspectRatio = 6 / 10,
  });
  
  @override
  Widget build(BuildContext context) {
    
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, 
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}