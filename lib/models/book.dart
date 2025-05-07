class Book {
  final int bookId;
  final int authorId;
  final String title;
  final String coverUrl;

  Book({
    required this.bookId,
    required this.authorId,
    required this.title,
    required this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['book_id'] as int,
      authorId: json['author_id'] as int,
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'book_id': bookId,
    'author_id': authorId,
    'title': title,
    'cover_url': coverUrl,
  };
}
