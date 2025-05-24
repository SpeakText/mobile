import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_provider.dart';
import '../core/widgets/book_card.dart';
import '../core/widgets/custom_bottom_nav_bar.dart';
import 'search_screen.dart';
import 'book_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color _topBgColor = Color(0xFFF8ECD1); // 밝은 베이지

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBooksAsync = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('글을 말하다',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: _topBgColor,
        elevation: 0,
      ),
      body: allBooksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('에러 발생: $e')),
        data: (books) {
          // 더미 데이터 기준 추천/신간/재생중 분리
          final recommended = books.take(5).toList();
          final newBooks = books.reversed.take(5).toList();

          String searchQuery = '';
          final TextEditingController searchController =
              TextEditingController();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // 검색창
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: '책 제목, 저자를 검색하세요',
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 0),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SearchScreen(initialQuery: value),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              // 추천 섹션
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('추천 오디오북',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recommended.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final book = recommended[index];
                    return BookCard(
                      title: book.title,
                      imageUrl: book.coverUrl,
                      author: '작가 ${book.authorId}',
                      width: 130,
                      height: 200,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // 신간 섹션
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('신간 오디오북',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: newBooks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final book = newBooks[index];
                    return BookCard(
                      title: book.title,
                      imageUrl: book.coverUrl,
                      author: '작가 ${book.authorId}',
                      width: 130,
                      height: 200,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(book: book),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
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
