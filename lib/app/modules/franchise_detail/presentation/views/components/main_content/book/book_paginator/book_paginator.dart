import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class BookPaginator extends StatefulWidget {
  final int totalItems;
  final int itemsPerPage;
  final int selectedPageIndex;
  final Function(int) onPageSelected;

  const BookPaginator({
    super.key,
    required this.totalItems,
    required this.itemsPerPage,
    required this.selectedPageIndex,
    required this.onPageSelected,
  });

  @override
  State<BookPaginator> createState() => _BookPaginatorState();
}




class _BookPaginatorState extends State<BookPaginator> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant BookPaginator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPageIndex != widget.selectedPageIndex) {
      _scrollToSelected();
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    
    final double targetOffset = widget.selectedPageIndex * 90.0;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalItems <= widget.itemsPerPage) return const SizedBox.shrink();

    final int totalPages = (widget.totalItems / widget.itemsPerPage).ceil();

    return Listener(
      onPointerSignal: (pointerSignal) {
        // Intercepta el evento de la rueda del ratón
        if (pointerSignal is PointerScrollEvent) {
          if (!_scrollController.hasClients) return;

          // Toma el desplazamiento vertical (scrollDelta.dy) y lo aplica al controller horizontal
          final double newOffset = _scrollController.offset + pointerSignal.scrollDelta.dy;

          _scrollController.jumpTo(
            newOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
          );
        }
      },
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: SizedBox(
          height: 48.0,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
            itemCount: totalPages,
            itemBuilder: (context, index) {
              final String label = 'Página ${index + 1}';
              final bool isSelected = widget.selectedPageIndex == index;

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: const Color(0xFF2B2845),
                  backgroundColor: AppColors.sidebarBackground,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (_) => widget.onPageSelected(index),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}