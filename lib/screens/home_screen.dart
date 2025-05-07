import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../core/widgets/book_card.dart';
import '../core/widgets/custom_bottom_nav_bar.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color _topBgColor = Color(0xFFF8ECD1); // 밝은 베이지

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBooksAsync = ref.watch(allBooksProvider);
    final recentBooksAsync = ref.watch(recentBooksProvider);
    final popularBooksAsync = ref.watch(popularBooksProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Container(
          color: _topBgColor,
          child: AppBar(
            title: const Text(
              '글을 말하다',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: true,
            backgroundColor: _topBgColor,
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '책 제목, 저자를 검색하세요',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blueAccent,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 0,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SearchScreen(initialQuery: value),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        children: [
          _SectionAsync(title: '최근 들은 책', booksAsync: recentBooksAsync),
          _SectionAsync(title: '인기 오디오북', booksAsync: popularBooksAsync),
          _SectionAsync(title: '전체 오디오북', booksAsync: allBooksAsync),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: 라우팅 연결 예정 또는 탭별 기능 구현
        },
      ),
      backgroundColor: Colors.grey[50],
    );
  }
}

class _SectionAsync extends StatelessWidget {
  final String title;
  final AsyncValue<List<Book>> booksAsync;
  const _SectionAsync({required this.title, required this.booksAsync});

  @override
  Widget build(BuildContext context) {
    return booksAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('에러 발생: $e')),
          ),
      data: (books) => _Section(title: title, books: books),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Book> books;
  const _Section({required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.blueAccent),
                onPressed: () {},
                splashRadius: 20,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(title: book.title, imageUrl: book.coverUrl);
            },
          ),
        ),
      ],
    );
  }
}
