import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$query"'),
      ),
      body: InfiniteVideoScrollView(searchQuery: query), // Pass the search query
    );
  }
}
