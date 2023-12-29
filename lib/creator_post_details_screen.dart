import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.

class MyScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const MyScreen({required this.post, super.key});
  @override
  State<MyScreen> createState() => MyScreenState();
}

class MyScreenState extends State<MyScreen> {
  late final Player player = Player();
  late final controller = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      enableHardwareAcceleration: true, // default: true
    ),
  );

  //MyScreenState({required this.post});

  List<VideoController> videoControllers = [];

  @override
  void initState() {
    super.initState();

    var playlist = <Media>[];

    for (var attachment in widget.post['attachments']) {
      if (attachment['path'].toLowerCase().endsWith('.mp4') ||
          attachment['path'].toLowerCase().endsWith('.m4v')) {
        //playlist.add(Media('https://coomer.su${attachment['path']}'));
        videoControllers.add(VideoController(
          player.open(Media('https://coomer.su${attachment['path']}'),
              play: false) as Player,
          configuration: const VideoControllerConfiguration(
            enableHardwareAcceleration: true,
          ),
        ));
      }
    }
    /*
    final playable2 = Playlist(
      [
        Media(
            'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373709-603a7a89-2105-4e1b-a5a5-a6c3567c9a59.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373716-76da0a4e-225a-44e4-9ee7-3e9006dbc3e3.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373718-86ce5e1d-d195-45d5-baa6-ef94041d0b90.mp4'),
        Media(
            'https://user-images.githubusercontent.com/28951144/229373720-14d69157-1a56-4a78-a2f4-d7a134d7c3e9.mp4'),
      ],
    );
    final playable = Playlist(playlist);*/

    //player.open(playable2, play: false);
  }

  @override
  void dispose() {
    player.dispose();
    // Dispose of each video controller
    for (var videoController in videoControllers) {
      videoController.player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Details'),
      ),
      body: ListView(
        children: [
          /*
          AspectRatio(
            aspectRatio: 9 / 16,
            child: Video(
              controller: controller,
              fill: Colors.red,
            ),
          ),
          AspectRatio(
            aspectRatio: 9 / 16,
            child: Video(
              controller: controller,
              fill: Colors.red,
            ),
          ),*/
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post['title'],
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.post['file']['path'],
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                // Display additional attachments

                for (var i = 0; i < widget.post['attachments'].length; i++)
                  _displayMedia(widget.post['attachments'][i]['path'], i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayMedia(String attachment, int index) {
    if (attachment.toLowerCase().endsWith('.mp4') ||
        attachment.toLowerCase().endsWith('.m4v')) {
      debugPrint("----------------------------------------------");
      debugPrint(attachment);
      return AspectRatio(
        aspectRatio: 9 / 16,
        child: Video(
          controller: videoControllers[index],
          fill: Colors.red,
        ),
      );
    } else {
      return _displayImage(attachment);
    }
  }

  Widget _displayImage(String imagePath) {
    return Image.network(
      'https://img.coomer.su/thumbnail/data$imagePath',
      //height: 200,
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    );
  }
}
