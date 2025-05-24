import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/book.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../core/controllers/audio_book_controller.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late AudioBookController _audioController;
  int _currentPage = 0;
  late final PageController _pageController;
  List<String> _pages = [];
  bool _isLoadingPages = false;

  @override
  void initState() {
    super.initState();
    _audioController = AudioBookController(book: widget.book);
    _audioController.init(() {
      if (mounted) setState(() {});
    }, _onAudioPositionChanged);
    _pageController = PageController();
    _loadOrCacheBookPages();
  }

  void _onAudioPositionChanged(Duration position) {
    final pageStartTimes = _audioController.pageStartTimes;
    if (pageStartTimes.isEmpty) return;
    final seconds = position.inMilliseconds / 1000.0;
    int newPage = 0;
    for (int i = 0; i < pageStartTimes.length; i++) {
      if (seconds >= pageStartTimes[i]) {
        newPage = i;
      } else {
        break;
      }
    }
    if (newPage != _currentPage && newPage < _pages.length) {
      setState(() {
        _currentPage = newPage;
      });
      _pageController.jumpToPage(newPage);
    }
  }

  Future<void> _loadOrCacheBookPages() async {
    setState(() => _isLoadingPages = true);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/book_${widget.book.bookId}_pages.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final loadedPages = List<String>.from(jsonDecode(content));
      setState(() {
        _pages = loadedPages;
        _isLoadingPages = false;
      });
    } else {
      final dummyPages = widget.book.pages;
      await file.writeAsString(jsonEncode(dummyPages));
      setState(() {
        _pages = dummyPages;
        _isLoadingPages = false;
      });
    }
  }

  @override
  void dispose() {
    _audioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final pages = _pages.isNotEmpty ? _pages : book.pages;
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        backgroundColor: const Color(0xFFF8ECD1),
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
                final pageStartTimes = _audioController.pageStartTimes;
                if (pageStartTimes.isNotEmpty &&
                    index < pageStartTimes.length &&
                    _audioController.isPlaying) {
                  _audioController.audioPlayer.seek(Duration(
                      milliseconds: (pageStartTimes[index] * 1000).toInt()));
                }
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Text(
                      pages[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${_currentPage + 1} / ${pages.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: _audioController.isDownloaded
                ? ElevatedButton.icon(
                    onPressed: _audioController.isLoading
                        ? null
                        : () {
                            setState(() => _audioController.isLoading = true);
                            _audioController.togglePlay((success, error) {
                              if (mounted) {
                                setState(() {});
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '오디오 재생/일시정지에 실패했습니다: $error')),
                                  );
                                }
                              }
                            });
                          },
                    icon: _audioController.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_audioController.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                    label:
                        Text(_audioController.isPlaying ? '일시정지' : '오디오북 재생'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDEB6AB),
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _audioController.isLoading
                        ? null
                        : () {
                            setState(() => _audioController.isLoading = true);
                            _audioController
                                .downloadOnlyAudio((success, error) {
                              if (mounted) {
                                setState(() {});
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('오디오 다운로드 완료!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('오디오 다운로드에 실패했습니다: $error')),
                                  );
                                }
                              }
                            });
                          },
                    icon: _audioController.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: const Text('다운로드'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDEB6AB),
                      foregroundColor: Colors.black87,
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
          // 임시: 로컬 오디오 파일 삭제 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _audioController.deleteAllLocalAudioFiles((deleted, error) {
                  if (mounted) {
                    setState(() {});
                    if (error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로컬 오디오 파일 $deleted개 삭제 완료')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('삭제 실패: $error')),
                      );
                    }
                  }
                });
              },
              icon: const Icon(Icons.delete_forever),
              label: const Text('로컬 오디오 파일 삭제 (임시)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
