import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_provider.dart';
import '../core/widgets/search_result_grid.dart';
import '../core/widgets/custom_bottom_nav_bar.dart';
import 'book_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    // TODO: 각 인덱스에 맞는 화면으로 이동 구현
    // 예시: if (index == 0) Navigator.pushReplacement(...)
  }

  @override
  Widget build(BuildContext context) {
    final allBooksAsync = ref.watch(allBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('검색', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '책 제목, 저자를 검색하세요',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_searchQuery.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  '검색어를 입력해 주세요',
                  style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                ),
              ),
            )
          else
            Expanded(
              child: allBooksAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) =>
                    Center(child: Text('에러 발생: $error')),
                data: (books) {
                  final filteredBooks = books.where((book) {
                    final searchLower = _searchQuery.toLowerCase();
                    return book.title.toLowerCase().contains(searchLower) ||
                        book.authorId.toString().contains(searchLower);
                  }).toList();
                  return SearchResultGrid(
                    books: filteredBooks,
                    onBookTap: (book) {
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
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // 검색이 두 번째 탭이라고 가정
        onTap: _onNavTap,
      ),
    );
  }
}
