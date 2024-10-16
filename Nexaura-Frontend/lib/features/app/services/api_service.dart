import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexaura/features/app/model/video_item.dart';
import 'package:nexaura/features/app/model/video_metadata.dart';

class ApiService {
  static String apiBaseUrl = 'http://192.168.246.131:3000/';
  final String apiUrl = '${apiBaseUrl}api/videos'; 

  Future<List<VideoItem>> fetchVideos(int page, {String? query}) async {
    final response = await http.get(Uri.parse('$apiUrl?page=$page'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }

  Future<VideoMetadata> fetchVideoMetadata(String objectId) async {
    final response = await http.get(Uri.parse('$apiUrl/metadata?objectId=$objectId'));
    if (response.statusCode == 200) {
      // Directly decode the single object from JSON
      Map<String, dynamic> data = json.decode(response.body);
      return VideoMetadata.fromJson(data);
    } else {
      throw Exception('Failed to load video metadata');
    }
  }


}
