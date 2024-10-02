import 'package:flutter/material.dart';
import 'package:nexaura/features/app/common/video_player.dart';
import 'package:nexaura/features/app/model/video_item.dart';

class VideoTile extends StatelessWidget {
  final VideoItem videoItem;

  VideoTile({required this.videoItem});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: videoItem.videoUrl),),
        );
              },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(videoItem.thumbnailUrl, fit: BoxFit.cover), // Thumbnail image
            SizedBox(height: 8),
            Text(
              videoItem.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => VideoPlayerScreen(videoUrl: videoItem.videoUrl),
            //       ),
            //     );
            //   },
            //   child: Text('Play Video'),
            // ),
          ],
        ),
      ),
    );
  }
}
