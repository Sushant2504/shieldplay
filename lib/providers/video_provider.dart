import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../utils/video_utils.dart';
import '../utils/constants.dart';
import 'dart:io';

class VideoProvider extends ChangeNotifier {
  final VideoService _videoService;
  final _yt = YoutubeExplode();
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  String? _error;
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _isBuffering = false;

  VideoProvider(this._videoService) {
    _initialize();
  }

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  VideoPlayerController? get controller => _controller;
  Duration get currentPosition => _controller?.value.position ?? Duration.zero;
  Duration get totalDuration => _controller?.value.duration ?? Duration.zero;
  double get aspectRatio => _controller?.value.aspectRatio ?? 16 / 9;

  Future<void> _initialize() async {
    try {
      _isInitialized = true;
      await loadVideos();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadVideos() async {
    if (!_isInitialized) return;
    
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load local videos
      final localVideos = await _videoService.getVideos();
      
      // Add YouTube videos
      final networkVideos = await _getYouTubeVideos();
      
      _videos = [...localVideos, ...networkVideos];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<VideoModel>> _getYouTubeVideos() async {
    final List<VideoModel> videoModels = [];
    
    try {
      // Use a list of predefined educational video IDs with direct URLs
      final videoList = [
        {
          'id': 'mv6C99LCcxg',
          'title': 'What is Doppler Effect',
          'duration': const Duration(minutes: 7, seconds: 22),
          'quality': '720p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        },
        {
          'id': '9bZkp7q19f0',
          'title': 'PSY - Gangnam Style',
          'duration': const Duration(minutes: 4, seconds: 13),
          'quality': '1080p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        },
        {
          'id': 'dQw4w9WgXcQ',
          'title': 'Physics: Wave Motion',
          'duration': const Duration(minutes: 3, seconds: 32),
          'quality': '720p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        },
        {
          'id': 'kJQP7kiw5Fk',
          'title': 'Chemistry: Atomic Structure',
          'duration': const Duration(minutes: 4, seconds: 22),
          'quality': '1080p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        },
        {
          'id': 'OPf0YbXqDm0',
          'title': 'Biology: Cell Division',
          'duration': const Duration(minutes: 3, seconds: 48),
          'quality': '720p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        },
        {
          'id': 'hT_nvWreIhg',
          'title': 'Computer Science: Algorithms',
          'duration': const Duration(minutes: 4, seconds: 1),
          'quality': '1080p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        },
        {
          'id': '09R8_2nJtjg',
          'title': 'Mathematics: Linear Algebra',
          'duration': const Duration(minutes: 3, seconds: 55),
          'quality': '720p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        },
        {
          'id': 'kJQP7kiw5Fk',
          'title': 'Physics: Quantum Mechanics',
          'duration': const Duration(minutes: 4, seconds: 22),
          'quality': '1080p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4',
        },
        {
          'id': 'OPf0YbXqDm0',
          'title': 'Chemistry: Chemical Bonding',
          'duration': const Duration(minutes: 3, seconds: 48),
          'quality': '720p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
        },
        {
          'id': 'hT_nvWreIhg',
          'title': 'Biology: DNA Structure',
          'duration': const Duration(minutes: 4, seconds: 1),
          'quality': '1080p',
          'url': 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4',
        },
      ];

      for (final video in videoList) {
        try {
          videoModels.add(VideoModel(
            id: video['id'] as String,
            title: video['title'] as String,
            path: video['url'] as String,
            duration: video['duration'] as Duration,
            thumbnail: 'https://res.cloudinary.com/dntep5naz/image/upload/v1749375494/thumbnail_ogbftf.jpg',
            source: VideoSource.network,
            isCached: false,
            quality: video['quality'] as String,
          ));
        } catch (e) {
          debugPrint('Error processing video ${video['id']}: $e');
          continue;
        }
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      // Add fallback videos if fetch fails
      videoModels.addAll([
        VideoModel(
          id: 'mv6C99LCcxg',
          title: 'What is Doppler Effect',
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
          duration: const Duration(minutes: 7, seconds: 22),
          thumbnail: 'https://res.cloudinary.com/dntep5naz/image/upload/v1749375494/thumbnail_ogbftf.jpg',
          source: VideoSource.network,
          isCached: false,
          quality: '720p',
        ),
        VideoModel(
          id: '9bZkp7q19f0',
          title: 'PSY - Gangnam Style',
          path: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          duration: const Duration(minutes: 4, seconds: 13),
          thumbnail: 'https://res.cloudinary.com/dntep5naz/image/upload/v1749375494/thumbnail_ogbftf.jpg',
          source: VideoSource.network,
          isCached: false,
          quality: '1080p',
        ),
      ]);
    }

    return videoModels;
  }

  Future<void> initializeVideo(VideoModel video) async {
    try {
      _controller?.dispose();
      _controller = null;
      _isPlaying = false;
      _isBuffering = true;
      notifyListeners();

      if (video.source == VideoSource.network) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(video.path));
      } else {
        _controller = VideoPlayerController.file(File(video.path));
      }

      await _controller!.initialize();
      _controller!.addListener(_videoListener);
      _isBuffering = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isBuffering = false;
      notifyListeners();
    }
  }

  void _videoListener() {
    if (_controller != null) {
      _isPlaying = _controller!.value.isPlaying;
      _isBuffering = _controller!.value.isBuffering;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (_controller == null) return;

    if (_isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null) return;
    await _controller!.seekTo(position);
  }

  Future<void> toggleVideoCache(VideoModel video) async {
    if (video.source != VideoSource.network) return;

    try {
      final index = _videos.indexWhere((v) => v.id == video.id);
      if (index == -1) return;

      if (video.isCached) {
        await _videoService.removeFromCache(video);
        _videos[index] = video.copyWith(isCached: false);
      } else {
        await _videoService.cacheVideo(video);
        _videos[index] = video.copyWith(isCached: true);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    try {
      await _videoService.clearCache();
      _videos = _videos.map((video) {
        if (video.source == VideoSource.network) {
          return video.copyWith(isCached: false);
        }
        return video;
      }).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
} 