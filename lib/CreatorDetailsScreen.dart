import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';


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
        posts = List<Map<String, dynamic>>.from(json.decode(utf8.decode(response.bodyBytes)));
      });
    } else {
      throw Exception('Failed to load user posts');
    }
  }

  Future<void> saveImageLocally(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/cached_images/${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
    } catch (e) {
      print('Error saving image: $e');
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

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
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
                              Text('${post['title']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                              Text('${post['content']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
