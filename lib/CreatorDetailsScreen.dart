import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
        posts = List<Map<String, dynamic>>.from(json.decode(response.body));
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${widget.creator['id']}'),
            Text('Name: ${widget.creator['name']}'),
            Text('Service: ${widget.creator['service']}'),
            SizedBox(height: 16),
            Text('Posts:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network('https://coomer.su${post['file']['path']}'),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Title: ${post['title']}'),
                              Text('Content: ${post['content']}'),
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
