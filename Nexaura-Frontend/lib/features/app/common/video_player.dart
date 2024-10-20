import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';
import 'package:nexaura/features/app/model/video_metadata.dart';
import 'package:nexaura/features/app/services/api_service.dart';
import 'better_player_manager.dart'; // Import your manager

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String objectId;

  const VideoPlayerScreen(
      {super.key, required this.videoUrl, required this.objectId});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  BetterPlayerController? _betterPlayerController;
  int views = 0, likes = 0, dislikes = 0;
  String title = '', description = '';
  bool isLiked = false, isDisliked = false, isLoading = true;
  DateTime uploadDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

Future<void> _initializePlayer() async {
  try {
    // Fetch video metadata
    VideoMetadata videoMetadata =
        await ApiService().fetchVideoMetadata(widget.objectId);

    // Fetch like/dislike status
    final status = await ApiService().fetchVideoStatus(widget.objectId);
    debugPrint("STATUS here! : "+ status['isLiked'].toString() + status['isDisliked'].toString());

    setState(() {
      views = videoMetadata.views;
      likes = videoMetadata.likes;
      dislikes = videoMetadata.dislikes;
      title = videoMetadata.title;
      description = videoMetadata.description;
      uploadDate = videoMetadata.uploadDate;
      isLiked = status['isLiked'];
      isDisliked = status['isDisliked'];
      isLoading = false;
    });

    // Update views when video starts
    _updateViews();
    _addToHistoryPlaylist();

    // Get the controller from BetterPlayerManager
    BetterPlayerController controller =
        BetterPlayerManager().getPlayerController(widget.videoUrl);

    setState(() {
      _betterPlayerController = controller;
    });
  } catch (e) {
    debugPrint("Error: $e");
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> _updateViews() async {
    await ApiService().incrementViews(widget.objectId);
    setState(() {
      views++;
    });
  }

  @override
  void dispose() {
    BetterPlayerManager().disposePlayer(); // Dispose the controller properly
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
                            description.isNotEmpty ? description : 'Loading...',
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
                              isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: isLiked ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () async {
                              try {
                                if (!isLiked) {
                                  await ApiService()
                                      .incrementLikes(widget.objectId);
                                  if (isDisliked) {
                                    await ApiService()
                                        .decrementDislikes(widget.objectId);
                                  }
                                } else {
                                  await ApiService()
                                      .decrementLikes(widget.objectId);
                                }
                                await ApiService().addToLike(widget.objectId);
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
                              } catch (e) {
                                debugPrint('Error updating like status: $e');
                              }
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
                            onPressed: () async {
                              try {
                                if (!isDisliked) {
                                  await ApiService()
                                      .incrementDislikes(widget.objectId);
                                  if (isLiked) {
                                    await ApiService()
                                        .decrementLikes(widget.objectId);
                                  }
                                } else {
                                  await ApiService()
                                      .decrementDislikes(widget.objectId);
                                }
                                await ApiService().addToDislike(widget.objectId);
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

                              } catch (e) {
                                print('Error updating dislike status: $e');
                              }
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
  
  Future<void> _addToHistoryPlaylist() async{
    if(await ApiService().addToHistory(widget.objectId)){
      debugPrint("Video added to the history!");
    }
    else{
      debugPrint("Video not added to the history!");
    }
  }
}
