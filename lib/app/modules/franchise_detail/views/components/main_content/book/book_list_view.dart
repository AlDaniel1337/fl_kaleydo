import 'package:flutter/material.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'book_tile/book_tile.dart';

class BookListView extends StatelessWidget {

  final List<FranchiseItemModel> items;
  final Function(int) onTap;
  final bool isBook;
   
  const BookListView({
    super.key, 
    required this.items,
    required this.onTap,
    this.isBook = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: 24, 
          vertical: isBook ? 12 : 4
        ),
        itemCount: items.length,
        itemBuilder: (ctx, idx) => BookTile(
          item: items[idx],
          isBook: isBook,
          onTap: () => onTap(idx),
        ), 
    );
  }
}