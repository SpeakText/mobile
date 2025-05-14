import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/book.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isDownloaded = false;
  String? _localFilePath;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  int _currentPage = 0;
  late final PageController _pageController;
  List<String> _pages = [];
  List<double> _pageStartTimes = [];
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) setState(() => _isPlaying = false);
      }
    });
    _positionSubscription =
        _audioPlayer.positionStream.listen(_onAudioPositionChanged);
    _checkLocalFile();
    _pageController = PageController();
    _loadOrCacheBookPages();
    _loadPageStartTimes();
  }

  void _loadPageStartTimes() {
    // Book 모델에서 pageStartTimes를 가져옴
    setState(() {
      _pageStartTimes = widget.book.pageStartTimes;
    });
  }

  void _onAudioPositionChanged(Duration position) {
    if (_pageStartTimes.isEmpty) return;
    final seconds = position.inMilliseconds / 1000.0;
    int newPage = 0;
    for (int i = 0; i < _pageStartTimes.length; i++) {
      if (seconds >= _pageStartTimes[i]) {
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

  Future<void> _checkLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${widget.book.bookId}.mp3';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      setState(() {
        _isDownloaded = true;
        _localFilePath = filePath;
      });
    }
  }

  Future<String> _downloadAudio() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${widget.book.bookId}.mp3';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }
    await Dio().download(widget.book.audioUrl, filePath);
    return filePath;
  }

  Future<void> _loadOrCacheBookPages() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/book_${widget.book.bookId}_pages.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      final loadedPages = List<String>.from(jsonDecode(content));
      setState(() {
        _pages = loadedPages;
      });
    } else {
      // 더미 데이터 사용 및 저장
      final dummyPages = widget.book.pages;
      await file.writeAsString(jsonEncode(dummyPages));
      setState(() {
        _pages = dummyPages;
      });
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // 오디오 다운로드만 수행하는 함수
  Future<void> _downloadOnlyAudio() async {
    setState(() => _isLoading = true);
    try {
      String? path = await _downloadAudio();
      if (mounted) {
        setState(() {
          _isDownloaded = true;
          _localFilePath = path;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('오디오 다운로드 완료!')),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오디오 다운로드에 실패했습니다: $e')),
        );
      }
    }
  }

  // 오디오 재생/일시정지만 수행하는 함수
  Future<void> _togglePlay() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      String? path = _localFilePath;
      if (path == null) {
        setState(() => _isLoading = false);
        return;
      }
      if (_isPlaying) {
        await _audioPlayer.pause();
        if (mounted)
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
      } else {
        if (mounted)
          setState(() {
            _isPlaying = true;
            _isLoading = false;
          });
        await _audioPlayer.setFilePath(path);
        await _audioPlayer.play();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오디오 재생/일시정지에 실패했습니다: $e')),
        );
      }
    }
  }

  // 모든 오디오북 mp3 파일 삭제 함수
  Future<void> _deleteAllLocalAudioFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir.listSync();
      int deleted = 0;
      for (var file in files) {
        if (file is File && file.path.endsWith('.mp3')) {
          await file.delete();
          deleted++;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로컬 오디오 파일 $deleted개 삭제 완료')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
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
                // 페이지 변경 시 오디오 seek
                if (_pageStartTimes.isNotEmpty &&
                    index < _pageStartTimes.length &&
                    _isPlaying) {
                  _audioPlayer.seek(Duration(
                      milliseconds: (_pageStartTimes[index] * 1000).toInt()));
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
            child: _isDownloaded
                ? ElevatedButton.icon(
                    onPressed: _isLoading ? null : _togglePlay,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(_isPlaying ? '일시정지' : '오디오북 재생'),
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
                    onPressed: _isLoading ? null : _downloadOnlyAudio,
                    icon: _isLoading
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
              onPressed: _deleteAllLocalAudioFiles,
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
