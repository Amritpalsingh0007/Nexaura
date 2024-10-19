import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HistoryPageView();
  }
}

class _HistoryPageView extends State<HistoryPage> {
  

  @override
  void dispose() {
    super.dispose(); // Call super.dispose() for proper disposal
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Videos")
      ),
      body: InfiniteVideoScrollView(history: true), // Pass the search query
    );
  }
}
