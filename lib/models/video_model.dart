

enum VideoSource {
  local,
  network,
}

class VideoModel {
  final String id;
  final String title;
  final String path;
  final Duration duration;
  final String thumbnail;
  final VideoSource source;
  final bool isCached;
  final Map<String, String> qualities;

  const VideoModel({
    required this.id,
    required this.title,
    required this.path,
    required this.duration,
    required this.thumbnail,
    required this.source,
    required this.isCached,
    required this.qualities,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? path,
    Duration? duration,
    String? thumbnail,
    VideoSource? source,
    bool? isCached,
    Map<String, String>? qualities,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
      source: source ?? this.source,
      isCached: isCached ?? this.isCached,
      qualities: qualities ?? this.qualities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'duration': duration.inSeconds,
      'thumbnail': thumbnail,
      'source': source.toString(),
      'isCached': isCached,
      'qualities': qualities,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      duration: Duration(seconds: json['duration'] as int),
      thumbnail: json['thumbnail'] as String,
      source: VideoSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => VideoSource.local,
      ),
      isCached: json['isCached'] as bool,
      qualities: Map<String, String>.from(json['qualities'] as Map),
    );
  }
}