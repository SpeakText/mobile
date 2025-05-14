class Book {
  final int bookId;
  final int authorId;
  final String title;
  final String coverUrl;
  final String audioUrl;
  final List<String> pages;
  final List<double> pageStartTimes;

  Book({
    required this.bookId,
    required this.authorId,
    required this.title,
    required this.coverUrl,
    required this.audioUrl,
    required this.pages,
    required this.pageStartTimes,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['book_id'] as int,
      authorId: json['author_id'] as int,
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String,
      audioUrl: json['audio_url'] as String,
      pages: List<String>.from(json['pages'] ?? []),
      pageStartTimes: (json['page_start_times'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'book_id': bookId,
        'author_id': authorId,
        'title': title,
        'cover_url': coverUrl,
        'audio_url': audioUrl,
        'pages': pages,
        'page_start_times': pageStartTimes,
      };
}
