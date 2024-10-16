import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;
  const SearchResultsPage({super.key, required this.query});

  @override
  State<StatefulWidget> createState() {
    return _SearchResultsPageView();
  }
}

class _SearchResultsPageView extends State<SearchResultsPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose(); // Call super.dispose() for proper disposal
  }

  void _startSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context, // Use Navigator.push to go to a new page
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(query: query),
        ),
      );
      _searchController.clear(); // Clear the search field after navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search videos...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black54),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 18),
          onSubmitted: (value) => _startSearch(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: InfiniteVideoScrollView(searchQuery: widget.query), // Pass the search query
    );
  }
}
