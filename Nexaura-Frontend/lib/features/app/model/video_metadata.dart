import 'package:nexaura/features/app/services/api_service.dart';

class VideoMetadata {
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final double duration;
  final int views;
  final int dislikes;
  final int likes;
  final DateTime uploadDate;
  final String uploaderId;

  VideoMetadata({required this.description, required this.videoUrl, required this.thumbnailUrl, required this.duration, required this.views, required this.dislikes, required this.likes, required this.uploadDate, required this.uploaderId, required this.title});

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      title: json['title'],
      description: json['description'],
      videoUrl : json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      views: json['views'],
      dislikes: json['dislikes'],
      likes: json['likes'],
      uploadDate: DateTime.fromMillisecondsSinceEpoch(json['uploadDate']),
      uploaderId: json['uploaderId'],
    );
  }
  String get thumbnailFullUrl => '${ApiService.apiBaseUrl}images/$thumbnailUrl';
  String get videoFullUrl => '${ApiService.apiBaseUrl}videos/${videoUrl.replaceFirst(".mp4", "")}_480p.mp4';
}
