import 'package:flutter/material.dart';
import '../../models/book.dart';
import 'book_card.dart';

class SearchResultGrid extends StatelessWidget {
  final List<Book> books;
  final VoidCallback? onBookTap;

  const SearchResultGrid({super.key, required this.books, this.onBookTap});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return BookCard(
          title: book.title,
          imageUrl: book.coverUrl,
          onTap: onBookTap,
        );
      },
    );
  }
}
