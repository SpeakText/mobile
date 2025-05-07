import '../models/book.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookService {
  // 전체 오디오북
  Future<List<Book>> fetchAllBooks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _dummyBooks;
  }

  // 최근 들은 책
  Future<List<Book>> fetchRecentBooks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyBooks.take(3).toList();
  }

  // 인기 오디오북
  Future<List<Book>> fetchPopularBooks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyBooks.reversed.take(4).toList();
  }

  // 내부 더미 데이터
  final List<Book> _dummyBooks = List.generate(
    10,
    (i) => Book(
      bookId: i + 1,
      authorId: 100 + i,
      title: '예시 오디오북 ${i + 1}',
      coverUrl: 'https://covers.openlibrary.org/b/id/${8231856 + i}-L.jpg',
    ),
  );
}

final bookServiceProvider = Provider((ref) => BookService());
