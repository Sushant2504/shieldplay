import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/video_provider.dart';
import '../providers/theme_provider.dart';
import '../models/video_model.dart';
import '../utils/constants.dart';
import '../utils/ui_utils.dart';
import '../utils/video_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isGridView = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Schedule the video loading after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadVideos();
      }
    });
  }

  Future<void> _loadVideos() async {
    if (!mounted) return;
    
    try {
      await context.read<VideoProvider>().loadVideos();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading videos: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<VideoModel> _filterVideos(List<VideoModel> videos) {
    if (_searchQuery.isEmpty) return videos;
    return videos.where((video) {
      return video.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = isDark ? Colors.grey[900]! : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark ? Colors.grey[800]! : Colors.white;
    final secondaryTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          AppConstants.appName,
          style: TextStyle(color: textColor),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search videos...',
                    hintStyle: TextStyle(color: secondaryTextColor),
                    prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: secondaryTextColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: secondaryTextColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                      borderSide: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              TabBar(
                controller: _tabController,
                indicatorColor: AppConstants.primaryColor,
                labelColor: AppConstants.primaryColor,
                unselectedLabelColor: secondaryTextColor,
                tabs: const [
                  Tab(text: 'Videos'),
                  Tab(text: 'Playlists'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: textColor,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: Icon(Icons.settings, color: textColor),
            onPressed: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
      body: Consumer<VideoProvider>(
        builder: (context, videoProvider, child) {
          if (!_isInitialized || videoProvider.isLoading) {
            return UiUtils.buildLoadingIndicator();
          }

          if (videoProvider.error != null) {
            return UiUtils.buildErrorWidget(
              videoProvider.error!,
              _loadVideos,
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildVideoList(
                videos: _filterVideos(videoProvider.videos),
                videoProvider: videoProvider,
                emptyMessage: 'No videos available',
                isDark: isDark,
                textColor: textColor,
                cardColor: cardColor,
              ),
              _buildPlaylistList(
                playlists: [
                  {
                    'title': 'Educational Videos',
                    'videos': videoProvider.videos.where((v) => v.source == VideoSource.network).toList(),
                  },
                  {
                    'title': 'Local Videos',
                    'videos': videoProvider.videos.where((v) => v.source == VideoSource.local).toList(),
                  },
                ] as List<Map<String, dynamic>>,
                videoProvider: videoProvider,
                isDark: isDark,
                textColor: textColor,
                cardColor: cardColor,
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppConstants.primaryColor,
        onPressed: () async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowMultiple: true,
              allowCompression: false,
            );

            if (result != null && result.files.isNotEmpty) {
              final videoProvider = context.read<VideoProvider>();
              for (final file in result.files) {
                if (file.path != null) {
                  await videoProvider.addLocalVideo(file.path!);
                }
              }
              UiUtils.showSnackBar(context, 'Videos added successfully');
            }
          } catch (e) {
            UiUtils.showSnackBar(context, 'Error picking videos: $e');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildVideoList({
    required List<VideoModel> videos,
    required VideoProvider videoProvider,
    required String emptyMessage,
    required bool isDark,
    required Color textColor,
    required Color cardColor,
  }) {
    if (videos.isEmpty) {
      return UiUtils.buildEmptyWidget(
        _searchQuery.isEmpty
            ? emptyMessage
            : 'No videos found matching "$_searchQuery"',
      );
    }

    return RefreshIndicator(
      onRefresh: () => videoProvider.loadVideos(),
      color: AppConstants.primaryColor,
      child: _isGridView ? _buildGridView(videos, videoProvider, isDark, textColor, cardColor) : _buildListView(videos, videoProvider, isDark, textColor, cardColor),
    );
  }

  Widget _buildGridView(
    List<VideoModel> videos, 
    VideoProvider videoProvider,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.gridSpacing),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: AppConstants.gridSpacing,
        mainAxisSpacing: AppConstants.gridSpacing,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildGridItem(context, video, videoProvider, isDark, textColor, cardColor);
      },
    );
  }

  Widget _buildListView(
    List<VideoModel> videos, 
    VideoProvider videoProvider,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return _buildListItem(context, video, videoProvider, isWideScreen, isDark, textColor, cardColor);
          },
        );
      },
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    VideoModel video,
    VideoProvider videoProvider,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    return GestureDetector(
      onTap: () => GoRouter.of(context).push('/player/${video.id}'),
      child: Card(
        color: cardColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: video.source == VideoSource.network
                  ? Image.network(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.video_library,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            size: 48,
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      video.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.video_library,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            size: 48,
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8)),
                ),
                child: Text(
                  VideoUtils.formatDuration(video.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            if (video.source == VideoSource.network)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    video.isCached ? Icons.cloud_done : Icons.cloud_download,
                    color: video.isCached ? Colors.green : Colors.white,
                    size: 20,
                  ),
                  onPressed: () => videoProvider.toggleVideoCache(video),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    VideoModel video,
    VideoProvider videoProvider,
    bool isWideScreen,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            width: isWideScreen ? 160 : 120,
            child: Stack(
              children: [
                video.source == VideoSource.network
                    ? Image.network(
                        video.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.video_library,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        video.thumbnail,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.video_library,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                              size: 48,
                            ),
                          );
                        },
                      ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: Text(
                      VideoUtils.formatDuration(video.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(
          video.title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isWideScreen ? 16 : 14,
          ),
          maxLines: isWideScreen ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (video.source == VideoSource.network)
              IconButton(
                icon: Icon(
                  video.isCached ? Icons.cloud_done : Icons.cloud_download,
                  color: video.isCached ? Colors.green : Colors.grey,
                  size: isWideScreen ? 24 : 20,
                ),
                onPressed: () => videoProvider.toggleVideoCache(video),
              ),
            IconButton(
              icon: Icon(
                Icons.play_arrow,
                color: AppConstants.primaryColor,
                size: isWideScreen ? 32 : 24,
              ),
              onPressed: () => GoRouter.of(context).push('/player/${video.id}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistList({
    required List<Map<String, dynamic>> playlists,
    required VideoProvider videoProvider,
    required bool isDark,
    required Color textColor,
    required Color cardColor,
  }) {
    if (playlists.isEmpty) {
      return UiUtils.buildEmptyWidget('No playlists available');
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Card(
          color: cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ExpansionTile(
            title: Text(
              playlist['title'] as String,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: (playlist['videos'] as List<VideoModel>).map((video) {
              return _buildListItem(context, video, videoProvider, true, isDark, textColor, cardColor);
            }).toList(),
          ),
        );
      },
    );
  }
} 