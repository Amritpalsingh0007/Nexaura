import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';

class LikePage extends StatefulWidget {
  const LikePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LikePageView();
  }
}

class _LikePageView extends State<LikePage> {
  

  @override
  void dispose() {
    super.dispose(); // Call super.dispose() for proper disposal
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liked Videos")
      ),
      body: InfiniteVideoScrollView(like: true), // Pass the search query
    );
  }
}
