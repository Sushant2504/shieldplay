import 'package:flutter/material.dart';

enum VideoSource {
  local,
  network,
  cache,
}

class VideoModel {
  final String id;
  final String title;
  final String path;
  final String thumbnail;
  final Duration duration;
  final VideoSource source;
  final bool isCached;
  final String? quality;

  const VideoModel({
    required this.id,
    required this.title,
    required this.path,
    required this.thumbnail,
    required this.duration,
    this.source = VideoSource.network,
    this.isCached = false,
    this.quality,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? path,
    String? thumbnail,
    Duration? duration,
    VideoSource? source,
    bool? isCached,
    String? quality,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      source: source ?? this.source,
      isCached: isCached ?? this.isCached,
      quality: quality ?? this.quality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'thumbnail': thumbnail, 
      'duration': duration.inSeconds,
      'source': source.toString(),
      'isCached': isCached,
      'quality': quality,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      thumbnail: json['thumbnail'] as String,
      duration: Duration(seconds: json['duration'] as int),
      source: VideoSource.values[json['source'] as int],
      isCached: json['isCached'] as bool? ?? false,
      quality: json['quality'] as String?,
    );
  }
}