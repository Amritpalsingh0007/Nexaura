import 'package:flutter/material.dart';
import 'package:nexaura/features/app/screen/result_view.dart';
import 'package:nexaura/features/app/screen/upload_video.dart';
import 'package:nexaura/features/app/common/infinite_video_scroll_view.dart';
import 'package:nexaura/theme/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
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
        title: !_isSearching
            ? Text(
                'Nexaura',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: lightColorScheme.primary,
                ),
              )
            : TextField(
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
      body: Column(
        children: [
          const Expanded(
            flex: 9,
            child: InfiniteVideoScrollView(),
          ),
          Expanded(
            flex: 1,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VideoUploadScreen(),
                  ),
                );
              },
              child: const Text("Upload"),
            ),
          ),
        ],
      ),
    );
  }
}
