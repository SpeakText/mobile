import 'package:just_audio/just_audio.dart';
import '../../models/book.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AudioBookController {
  final Book book;
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  bool isDownloaded = false;
  String? localFilePath;
  List<double> pageStartTimes = [];
  StreamSubscription<PlayerState>? playerStateSubscription;
  StreamSubscription<Duration>? positionSubscription;

  AudioBookController({required this.book});

  Future<void> init(
      Function onComplete, Function(Duration) onAudioPositionChanged) async {
    playerStateSubscription = audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying = false;
        onComplete();
      }
    });
    positionSubscription =
        audioPlayer.positionStream.listen(onAudioPositionChanged);
    await checkLocalFile();
    pageStartTimes = book.pageStartTimes;
  }

  Future<void> dispose() async {
    await playerStateSubscription?.cancel();
    await positionSubscription?.cancel();
    await audioPlayer.dispose();
  }

  Future<void> checkLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${book.bookId}.mp3';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      isDownloaded = true;
      localFilePath = filePath;
    }
  }

  Future<String> downloadAudio() async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'audio_${book.bookId}.mp3';
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }
    await Dio().download(book.audioUrl, filePath);
    return filePath;
  }

  Future<void> downloadOnlyAudio(Function(bool, String?) onComplete) async {
    isLoading = true;
    try {
      String? path = await downloadAudio();
      isDownloaded = true;
      localFilePath = path;
      isLoading = false;
      onComplete(true, null);
    } catch (e) {
      isLoading = false;
      onComplete(false, e.toString());
    }
  }

  Future<void> togglePlay(Function(bool, String?) onComplete) async {
    isLoading = true;
    try {
      String? path = localFilePath;
      if (path == null) {
        isLoading = false;
        onComplete(false, null);
        return;
      }
      if (isPlaying) {
        await audioPlayer.pause();
        isPlaying = false;
        isLoading = false;
        onComplete(true, null);
      } else {
        isPlaying = true;
        isLoading = false;
        await audioPlayer.setFilePath(path);
        await audioPlayer.play();
        onComplete(true, null);
      }
    } catch (e) {
      isLoading = false;
      onComplete(false, e.toString());
    }
  }

  Future<void> deleteAllLocalAudioFiles(
      Function(int, String?) onComplete) async {
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
      onComplete(deleted, null);
    } catch (e) {
      onComplete(0, e.toString());
    }
  }
}
