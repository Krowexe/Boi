import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../tools/saveImageLocally.dart';

class InstagramCard extends StatelessWidget {
  final Map<String, dynamic> post;

  InstagramCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        'https://img.coomer.su/thumbnail/data${post['file']['path']}';

    // Save the image locally when it is first loaded
    saveImageLocally(imageUrl);

    // Determine if the URL is a video based on the file extension or any other metadata
    bool isVideo = imageUrl.toLowerCase().endsWith('.mp4');

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 0, // Adjust the elevation for a shadow effect
      child: InkWell(
        onTap: () {
          // Handle card tap
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
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
