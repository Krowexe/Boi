import 'package:flutter/material.dart';

class CreatorDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> creator;

  CreatorDetailsScreen({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${creator['name']} - ${creator['service']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${creator['id']}'),
            Text('Name: ${creator['name']}'),
            Text('Service: ${creator['service']}'),
          ],
        ),
      ),
    );
  }
}
