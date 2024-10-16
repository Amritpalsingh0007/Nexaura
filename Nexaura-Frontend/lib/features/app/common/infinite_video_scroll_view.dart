import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/video_tile.dart';
import 'package:nexaura/features/app/model/video_item.dart';
import 'package:nexaura/features/app/services/api_service.dart';
import 'package:nexaura/global/common/toast.dart';

class InfiniteVideoScrollView extends StatefulWidget {
  final String? searchQuery; // Optional search query

  const InfiniteVideoScrollView({super.key, this.searchQuery});

  @override
  State<InfiniteVideoScrollView> createState() =>
      _InfiniteVideoScrollViewState();
}

class _InfiniteVideoScrollViewState extends State<InfiniteVideoScrollView> {
  final List<VideoItem> _videos = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMoreData = true;
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();

    _fetchVideos();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _fetchMoreVideos();
      }
    });
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<VideoItem> fetchedVideos;
      if(widget.searchQuery == null){
        fetchedVideos = await ApiService().fetchVideos(
          _page, 
        );

      } else{
        fetchedVideos = await ApiService().searchVideos(_page, widget.searchQuery!);
      }

      setState(() {
        _videos.addAll(fetchedVideos);
        _page++;
        if (fetchedVideos.length < 10) {
          _hasMoreData = false;
        }
      });
    } catch (e) {
      showToast(message: 'Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMoreVideos() async {
    if (_isLoading || !_hasMoreData) return;
    await _fetchVideos();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading && _videos.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.all(10),
            itemCount: _videos.length + (_hasMoreData ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _videos.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return VideoTile(videoItem: _videos[index]);
            },
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
