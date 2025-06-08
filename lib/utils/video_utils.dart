import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';
import 'constants.dart';

class VideoUtils {
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  static String getFileSizeString(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  static bool isVideoFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceAll('.', '');
    return AppConstants.supportedFormats.contains(extension);
  }

  static Future<Duration> getVideoDuration(String filePath) async {
    try {
      final controller = VideoPlayerController.file(File(filePath));
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration;
    } catch (e) {
      return Duration.zero;
    }
  }

  static String getVideoTitle(String filePath) {
    return path.basenameWithoutExtension(filePath);
  }

  static String getVideoThumbnail(String filePath) {
    // TODO: Implement video thumbnail generation
    return 'assets/images/video_placeholder.png';
  }

  static Future<VideoModel> createVideoModel(String filePath) async {
    final duration = await getVideoDuration(filePath);
    return VideoModel(
      id: filePath,
      title: getVideoTitle(filePath),
      path: filePath,
      duration: duration,
      thumbnail: getVideoThumbnail(filePath),
      source: VideoSource.local,
      isCached: false,
      qualities: {'auto': filePath},
    );
  }

  static String getNetworkVideoId(String url) {
    // Generate a unique ID for network videos
    return url.hashCode.toString();
  }

  static bool isNetworkVideo(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  static String getCachePath(String videoId) {
    return path.join(AppConstants.cacheDirectory, '$videoId.mp4');
  }

  static Future<bool> isVideoCached(String videoId) async {
    final cacheFile = File(getCachePath(videoId));
    return await cacheFile.exists();
  }

  static Future<void> clearVideoCache(String videoId) async {
    final cacheFile = File(getCachePath(videoId));
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
  }
} 