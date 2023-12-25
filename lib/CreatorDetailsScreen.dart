import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'tools/saveImageLocally.dart';
import 'ui/InstagramCard.dart';
import 'ui/SimpleCard.dart';

class CreatorDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> creator;

  CreatorDetailsScreen({required this.creator});

  @override
  _CreatorDetailsScreenState createState() => _CreatorDetailsScreenState();
}

class _CreatorDetailsScreenState extends State<CreatorDetailsScreen> {
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    fetchUserPosts();
  }

  Future<void> fetchUserPosts() async {
    final String service = widget.creator['service'];
    final String id = widget.creator['id'];
    final Uri url = Uri.parse('https://coomer.su/api/v1/$service/user/$id');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        posts = List<Map<String, dynamic>>.from(
            json.decode(utf8.decode(response.bodyBytes)));
      });
    } else {
      throw Exception('Failed to load user posts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.creator['name']} - ${widget.creator['service']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  final imageUrl = 'https://coomer.su${post['file']['path']}';

                  // Save the image locally when it is first loaded
                  saveImageLocally(imageUrl);

                  return InstagramCard(
                    post: post, // Pass post as a parameter
                  );
                  /*
                  return SimpleCard(
                    post: post, // Pass post as a parameter
                  );*/
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
