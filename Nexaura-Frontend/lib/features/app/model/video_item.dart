import 'package:nexaura/features/app/services/api_service.dart';

class VideoItem {
  final String uuid;
  final String title;
  final String objectId;

  VideoItem({required this.uuid, required this.title, required this.objectId});

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      uuid: json['uuid'],
      title: json['title'],
      objectId: json['objectId']
    );
  }
  String get thumbnailUrl => '${ApiService.apiBaseUrl}images/$uuid.jpg';
  String get videoUrl => '${ApiService.apiBaseUrl}videos/${uuid}_480p.mp4';
}
