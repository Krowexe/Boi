import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<void> saveImageLocally(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;

      // Create the directory if it doesn't exist
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/cached_images/');
      if (!imagesDir.existsSync()) {
        imagesDir.createSync(recursive: true);
      }

      // Generate a unique filename based on the current timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final file = File('${imagesDir.path}/$timestamp.png');

      // Write image bytes to the file
      await file.writeAsBytes(bytes);
    } catch (e) {
      print('Error saving image: $e');
    }
  }