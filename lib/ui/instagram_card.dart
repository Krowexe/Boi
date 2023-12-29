import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.
import '../tools/saveImageLocally.dart';
import '../creator_post_details_screen.dart';

class InstagramCard extends StatelessWidget {
  final Map<String, dynamic> post;

  InstagramCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        'https://img.coomer.su/thumbnail/data${post['file']['path']}';

    // Save the image locally when it is first loaded
    saveImageLocally(imageUrl);

    // Create a new Player and VideoController for each instance of InstagramCard
    final player = Player();
    final controller = VideoController(player);

    // Determine if the URL is a video based on the file extension or any other metadata
    bool isVideo = (imageUrl.toLowerCase().endsWith('.mp4') ||
        imageUrl.toLowerCase().endsWith('.m4v'));

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 0, // Adjust the elevation for a shadow effect
      child: InkWell(
        onTap: () {
          // Handle card tap
          //if (isVideo) {
          // Open video when tapped
          //player.open(Media('https://coomer.su${post['file']['path']}'));
          //}
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyScreen(post: post),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isVideo) ...[
              VideoPlayerWidget(controller: controller),
            ] else ...[
              CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    post['content'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  // Add more details or icons if needed
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 18),
                      SizedBox(width: 4),
                      Text(
                        Random().nextInt(100).toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 16),
                      // Add more icons or details here
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
class VideoPlayerWidget extends StatelessWidget {
  final VideoController controller;

  VideoPlayerWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Use AspectRatio to maintain a specific aspect ratio for the video player
    return SizedBox(
      //aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.width * 9.0 / 16.0,
      child: Video(controller: controller),
    );
  }
}*/

class VideoPlayerWidget extends StatefulWidget {
  final VideoController controller;

  VideoPlayerWidget({required this.controller});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Start/stop playback when the player area is tapped
        if (isPlaying) {
          widget.controller.player.pause();
        } else {
          widget.controller.player.play();
        }
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Video(controller: widget.controller),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    widget.controller.player.dispose();
    super.dispose();
  }
}
