class VideoModel {
  final String id;
  final String title;
  final String path;
  final String thumbnail;
  final Duration duration;
  bool isCached;

  VideoModel({
    required this.id,
    required this.title,
    required this.path,
    required this.thumbnail,
    required this.duration,
    this.isCached = false,
  });

  VideoModel copyWith({
    String? id,
    String? title,
    String? path,
    String? thumbnail,
    Duration? duration,
    bool? isCached,
  }) {
    return VideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      path: path ?? this.path,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      isCached: isCached ?? this.isCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'thumbnail': thumbnail, 
      'duration': duration.inSeconds,
      'isCached': isCached,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      path: json['path'] as String,
      thumbnail: json['thumbnail'] as String,
      duration: Duration(seconds: json['duration'] as int),
      isCached: json['isCached'] as bool? ?? false,
    );
  }
}