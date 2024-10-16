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
          MaterialPageRoute(builder: (context) => VideoPlayerScreen(videoUrl: videoItem.videoUrl, objectId: videoItem.objectId,),),
        );
              },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width * 9 / 16,
               child: Image.network(
                videoItem.thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child; 
                  } else {
                    
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),),
            const SizedBox(height: 8),
            Text(
              videoItem.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
    );
  }
}
