import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';
import 'package:nexaura/features/app/model/video_metadata.dart';
import 'package:nexaura/features/app/services/api_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String objectId;

  const VideoPlayerScreen({required this.videoUrl, required this.objectId});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  BetterPlayerController? _betterPlayerController;
  int views = 0;
  int likes = 0;
  int dislikes = 0;
  String title = '';
  String description = '';
  bool isLiked = false;
  bool isDisliked = false;
  bool isLoading = true;
  DateTime uploadDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      VideoMetadata videoMetadata =
          await ApiService().fetchVideoMetadata(widget.objectId);
      setState(() {
        views = videoMetadata.views;
        likes = videoMetadata.likes;
        dislikes = videoMetadata.dislikes;
        title = videoMetadata.title;
        description = videoMetadata.description;
        uploadDate = videoMetadata.uploadDate;
        isLoading = false;
      });

      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
      );

      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          autoPlay: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enableFullscreen: true,
            enableSkips: true,
            skipBackIcon: Icons.replay_10,
            skipForwardIcon: Icons.forward_10,
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_betterPlayerController?.isPlaying() == true) {
          _betterPlayerController?.pause();
        }
        return true;
      },
      child: Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Player
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 9 / 16,
                      child: _betterPlayerController != null
                          ? BetterPlayer(controller: _betterPlayerController!)
                          : const Center(child: CircularProgressIndicator()),
                    ),
                    const SizedBox(height: 10),

                    // Expandable Title and Description Block
                    ExpansionTile(
                        title: Text(
                          title.isNotEmpty ? title : 'Loading...',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '$views views • ${_formatDate(uploadDate)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              description.isNotEmpty
                                  ? description
                                  : 'Loading...',
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 10),

                    // Like & Dislike Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (!isLiked) {
                                  likes++;
                                  if (isDisliked) {
                                    dislikes--;
                                    isDisliked = false;
                                  }
                                } else {
                                  likes--;
                                }
                                isLiked = !isLiked;
                              });
                            },
                          ),
                          Text('$likes', style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(
                              isDisliked
                                  ? Icons.thumb_down
                                  : Icons.thumb_down_outlined,
                              color: isDisliked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                if (!isDisliked) {
                                  dislikes++;
                                  if (isLiked) {
                                    likes--;
                                    isLiked = false;
                                  }
                                } else {
                                  dislikes--;
                                }
                                isDisliked = !isDisliked;
                              });
                            },
                          ),
                          Text('$dislikes',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),

                    // Infinite Scroll View for Related Videos
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Related Videos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 400,
                      child: InfiniteVideoScrollView(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 1) {
      return 'Today';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      return '${(difference / 7).floor()} weeks ago';
    } else if (difference < 365) {
      return '${(difference / 30).floor()} months ago';
    } else {
      return '${(difference / 365).floor()} years ago';
    }
  }
}
