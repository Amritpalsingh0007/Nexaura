import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nexaura/features/app/model/video_item.dart';
import 'package:nexaura/features/app/model/video_metadata.dart';

class ApiService {
  static const String apiBaseUrl = 'http://192.168.246.57:3000/';
  final String apiUrl = '${apiBaseUrl}api/videos';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;

  Future<String?> _getUserId() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  /// Fetches a paginated list of videos.
  Future<List<VideoItem>> fetchVideos(int page) async {
    final response = await http.get(Uri.parse('$apiUrl?page=$page'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  /// Searches videos by query and page.
  Future<List<VideoItem>> searchVideos(int page, String query) async {
    final response =
        await http.get(Uri.parse('$apiUrl/search?page=$page&query=$query'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  /// Fetches metadata of a specific video by its ObjectId.
  Future<VideoMetadata> fetchVideoMetadata(String objectId) async {
    final response =
        await http.get(Uri.parse('$apiUrl/metadata?objectId=$objectId'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return VideoMetadata.fromJson(data);
    } else {
      throw Exception('Failed to load video metadata');
    }
  }

  Future<bool> incrementViews(String objectId) async {
    try {
      final response = await http.patch(
        Uri.parse('$apiUrl/increment-views'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'objectId': objectId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
            'Failed to update data. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating data: $e');
      return false;
    }
  }

  // Increment likes for a specific video
  Future<void> incrementLikes(String objectId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/increment-likes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'objectId': objectId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to increment likes');
    }
  }

  // Decrement likes for a specific video
  Future<void> decrementLikes(String objectId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/decrement-likes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'objectId': objectId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to decrement likes');
    }
  }

  // Increment dislikes for a specific video
  Future<void> incrementDislikes(String objectId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/increment-dislikes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'objectId': objectId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to increment dislikes');
    }
  }

  // Decrement dislikes for a specific video
  Future<void> decrementDislikes(String objectId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/decrement-dislikes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'objectId': objectId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to decrement dislikes');
    }
  }

  Future<Map<String, dynamic>> fetchVideoStatus(String objectId) async {
    try {
      // Wait for the user ID
      String? userId = await _getUserId();

      final response = await http.post(
        Uri.parse('$apiUrl/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'objectId': objectId,
          'userId': userId ?? "No user", // Use fallback if userId is null
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch video status');
      }
    } catch (e) {
      debugPrint('Error fetching video status: $e');
      throw Exception('Failed to fetch video status');
    }
  }

  Future<bool> addToHistory(String videoId) async{
    String? userId = await _getUserId();
    final response = await http.post(
      Uri.parse('${apiBaseUrl}api/playlist/history'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId ?? "User Id",'videoId': videoId}),
    );
    if (response.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<bool> addToLike(String videoId) async{
    String? userId = await _getUserId();
    final response = await http.post(
      Uri.parse('${apiBaseUrl}api/playlist/like'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId ?? "User Id",'videoId': videoId}),
    );
    if (response.statusCode != 200) {
      debugPrint("Something went wrong! cant add video to playlist"+ response.statusCode.toString());
      return false;
    }
    return true;
  }  

  Future<bool> addToDislike(String videoId) async{
    String? userId = await _getUserId();
    final response = await http.post(
      Uri.parse('${apiBaseUrl}api/playlist/dislike'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId ?? "User Id",'videoId': videoId}),
    );
    if (response.statusCode != 200) {
      debugPrint("Something went wrong! cant add video to playlist"+ response.statusCode.toString());
      return false;
    }
    return true;
  }

  Future<List<VideoItem>> fetchLikedVideos(int page) async {
    String? userId = await _getUserId();
    final response = await http.post(Uri.parse('${apiBaseUrl}api/playlist/likevideo'),
    headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"page" : page, 'userId': userId ?? "No user"}));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<List<VideoItem>> fetchHistoryVideos(int page) async {
    String? userId = await _getUserId();
    final response = await http.post(Uri.parse('${apiBaseUrl}api/playlist/historyvideo'),
    headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"page" : page, 'userId': userId ?? "No user"}));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
