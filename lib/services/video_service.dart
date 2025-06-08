import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../models/video_model.dart';
import '../utils/video_utils.dart';
import '../utils/constants.dart';

class VideoService {
  static const String _cachedVideosKey = 'cached_videos';
  static const int _maxCacheSize = 5;
  static List<VideoModel>? _cachedVideoList;
  static const String _cacheDirName = 'video_cache';
  late Directory _cacheDir;

  Future<void> initialize() async {
    // Request storage permissions
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/$_cacheDirName');
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }
  }

  Future<List<VideoModel>> getVideos() async {
    try {
      final localVideos = await _getLocalVideos();
      return localVideos;
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  Future<List<VideoModel>> _getLocalVideos() async {
    final List<VideoModel> videos = [];
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      
      for (var file in files) {
        if (file is File && VideoUtils.isVideoFile(file.path)) {
          final video = await VideoUtils.createVideoModel(file.path);
          videos.add(video);
        }
      }
    } catch (e) {
      print('Error loading local videos: $e');
    }
    return videos;
  }

  Future<List<VideoModel>> _getNetworkVideos() async {
    // TODO: Implement network video fetching
    return [
      VideoModel(
        id: 'network1',
        title: 'Sample Network Video 1',
        path: 'https://example.com/video1.mp4',
        thumbnail: 'https://example.com/thumbnail1.jpg',
        duration: const Duration(minutes: 5),
        source: VideoSource.network,
      ),
    ];
  }

  bool _isVideoFile(String path) {
    final videoExtensions = [
      '.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v',
      '.3gp', '.ts', '.mts', '.m2ts', '.vob', '.ogv', '.mxf', '.rm', '.rmvb'
    ];
    return videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  Future<void> cacheVideo(VideoModel video) async {
    if (video.source != VideoSource.network) return;

    try {
      final response = await http.get(Uri.parse(video.path as String));
      if (response.statusCode == 200) {
        final cacheDir = await _getCacheDirectory();
        final cacheFile = File('${cacheDir.path}/${video.id}.mp4');
        await cacheFile.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception('Failed to download video: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cache video: $e');
    }
  }

  Future<void> removeFromCache(VideoModel video) async {
    if (video.source != VideoSource.network) return;

    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/${video.id}.mp4');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to remove video from cache: $e');
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
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
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

  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/${AppConstants.cacheDirectory}');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }
} 