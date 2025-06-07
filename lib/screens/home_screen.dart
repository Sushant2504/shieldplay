import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../models/video_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    await context.read<VideoProvider>().loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Video Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () => GoRouter.of(context).push('/security-status'),
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, child) {
          if (videoProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (videoProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${videoProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadVideos,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (videoProvider.videos.isEmpty) {
            return const Center(
              child: Text('No videos available'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadVideos,
            child: ListView.builder(
              itemCount: videoProvider.videos.length,
              itemBuilder: (context, index) {
                final video = videoProvider.videos[index];
                return _buildVideoItem(context, video, videoProvider);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoItem(
    BuildContext context,
    VideoModel video,
    VideoProvider videoProvider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            video.thumbnail,
            width: 80,
            height: 45,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 45,
                color: Colors.grey[300],
                child: const Icon(Icons.video_library),
              );
            },
          ),
        ),
        title: Text(video.title),
        subtitle: Text(
          'Duration: ${_formatDuration(video.duration)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                video.isCached ? Icons.cloud_done : Icons.cloud_download,
                color: video.isCached ? Colors.green : null,
              ),
              onPressed: () => videoProvider.toggleCache(video),
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => GoRouter.of(context).push('/player/${video.id}'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
} 