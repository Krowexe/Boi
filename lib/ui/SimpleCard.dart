import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../tools/saveImageLocally.dart';

class SimpleCard extends StatelessWidget {
  final Map<String, dynamic> post;

  SimpleCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'https://coomer.su${post['file']['path']}';

    // Save the image locally when it is first loaded
    saveImageLocally(imageUrl);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      //elevation: 2, // Adjust the elevation for a shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10000),
      ),
      color: Colors.transparent,
      child: InkWell(
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
                  Text('${post['title']}',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal)),
                  Text('${post['content']}',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
