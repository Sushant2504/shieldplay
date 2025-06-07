import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';

class VideoService {
  static const String _cachedVideosKey = 'cached_videos';
  static const int _maxCacheSize = 5;
  static List<VideoModel>? _cachedVideoList;
  static const String _cacheDirName = 'video_cache';
  late Directory _cacheDir;

  Future<void> initialize() async {
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/$_cacheDirName');
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
  }

  Future<List<VideoModel>> getAvailableVideos() async {
    if (_cachedVideoList != null) {
      return _cachedVideoList!;
    }

    // TODO: Implement actual video fetching from a server
    final videos = [
      VideoModel(
        id: '1',
        title: 'Sample Video 1',
        path: 'https://example.com/video1.mp4',
        thumbnail: 'https://example.com/thumbnail1.jpg',
        duration: const Duration(minutes: 5),
      ),
      VideoModel(
        id: '2',
        title: 'Sample Video 2',
        path: 'https://example.com/video2.mp4',
        thumbnail: 'https://example.com/thumbnail2.jpg',
        duration: const Duration(minutes: 10),
      ),
    ];

    _cachedVideoList = videos;
    return videos;
  }

  Future<void> cacheVideo(VideoModel video) async {
    final fileName = _getFileNameFromPath(video.path);
    final cachedFile = File('${_cacheDir.path}/$fileName');

    if (await cachedFile.exists()) {
      return;
    }

    // Check cache size and remove oldest if needed
    final cachedFiles = await _cacheDir.list().toList();
    if (cachedFiles.length >= _maxCacheSize) {
      final oldestFile = cachedFiles.first;
      if (oldestFile is File) {
        await oldestFile.delete();
      }
    }

    try {
      final response = await http.get(Uri.parse(video.path));
      if (response.statusCode == 200) {
        await cachedFile.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error caching video: $e');
    }
  }

  Future<void> removeFromCache(String path) async {
    final fileName = _getFileNameFromPath(path);
    final cachedFile = File('${_cacheDir.path}/$fileName');
    if (await cachedFile.exists()) {
      await cachedFile.delete();
    }
  }

  Future<List<String>> getCachedVideos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_cachedVideosKey) ?? [];
    } catch (error) {
      print('Error getting cached videos: $error');
      return [];
    }
  }

  bool isVideoCached(String path) {
    final fileName = _getFileNameFromPath(path);
    final cachedFile = File('${_cacheDir.path}/$fileName');
    return cachedFile.existsSync();
  }

  String getCacheDirectory() {
    return _cacheDir.path;
  }

  File? getCachedVideoFile(String path) {
    final fileName = _getFileNameFromPath(path);
    final cachedFile = File('${_cacheDir.path}/$fileName');
    return cachedFile.existsSync() ? cachedFile : null;
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedVideos = prefs.getStringList(_cachedVideosKey) ?? [];
      
      for (final videoPath in cachedVideos) {
        await removeFromCache(videoPath);
      }
      
      await prefs.setStringList(_cachedVideosKey, []);
      _cachedVideoList = null;
    } catch (error) {
      print('Error clearing cache: $error');
      rethrow;
    }
  }

  Future<int> getCacheSize() async {
    int totalSize = 0;
    if (await _cacheDir.exists()) {
      final files = await _cacheDir.list().toList();
      for (var file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
    }
    return totalSize;
  }

  String _getFileNameFromPath(String path) {
    return path.split('/').last;
  }
} 