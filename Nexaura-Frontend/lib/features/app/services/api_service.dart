import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexaura/features/app/model/video_item.dart';

class ApiService {
  static String apiBaseUrl = 'http://192.168.207.11:3000/';
  final String apiUrl = '${apiBaseUrl}api/videos'; 

  Future<List<VideoItem>> fetchVideos(int page) async {
    final response = await http.get(Uri.parse('$apiUrl?page=$page'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => VideoItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load videos');
    }
  }
}
