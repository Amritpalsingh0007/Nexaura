import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/video_tile.dart';
import 'package:nexaura/features/app/model/video_item.dart';
import 'package:nexaura/features/app/services/api_service.dart';
import 'package:nexaura/global/common/toast.dart';
import 'package:nexaura/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<VideoItem> _videos = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos();

    // Detect when the user scrolls to the bottom and load more videos
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchMoreVideos();
      }
    });
  }

  // Fetch initial or more videos
  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedVideos = await ApiService().fetchVideos(_page);
      setState(() {
        _videos.addAll(fetchedVideos);
        _page++;
        if (fetchedVideos.length < 10) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      showToast(message: 'Error: $e');
      print("\n\n Error : \n $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch more videos when the user scrolls to the bottom
  Future<void> _fetchMoreVideos() async {
    if (_isLoading || !_hasMoreData) return;

    await _fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nexaura', style: TextStyle(fontSize: 27,fontWeight: FontWeight.bold, color: lightColorScheme.primary),)),
      body: _isLoading && _videos.isEmpty
          ? const Center(child: CircularProgressIndicator()) 
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: _videos.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _videos.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return VideoTile(videoItem: _videos[index]);
              },
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
