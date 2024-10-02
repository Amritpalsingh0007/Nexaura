import 'package:nexaura/features/app/services/api_service.dart';

class VideoItem {
  final String uuid;
  final String title;

  VideoItem({required this.uuid, required this.title});

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      uuid: json['uuid'],
      title: json['title'],
    );
  }
  String get thumbnailUrl => '${ApiService.apiBaseUrl}images/$uuid.jpg';
  String get videoUrl => '${ApiService.apiBaseUrl}videos/$uuid.mp4';
}
