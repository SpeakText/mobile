import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../services/book_service.dart';

final bookServiceProvider = Provider((ref) => BookService());

final allBooksProvider = FutureProvider<List<Book>>((ref) async {
  final service = ref.read(bookServiceProvider);
  return service.fetchAllBooks();
});

final recentBooksProvider = FutureProvider<List<Book>>((ref) async {
  final service = ref.read(bookServiceProvider);
  return service.fetchRecentBooks();
});

final popularBooksProvider = FutureProvider<List<Book>>((ref) async {
  final service = ref.read(bookServiceProvider);
  return service.fetchPopularBooks();
});
