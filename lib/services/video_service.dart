import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoService {
  Future<List<String>> getLocalVideoPaths() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/videos');

      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      final files = await videoDir.list().toList();
      final videoPaths = files
          .where((file) => file is File &&
          (file.path.endsWith('.mp4') ||
              file.path.endsWith('.mov') ||
              file.path.endsWith('.avi')))
          .map((file) => file.path)
          .toList();
      
      return [
        'assets/videos/video1.mp4',
        'assets/videos/video2.mp4',
        'assets/videos/video3.mp4',
      ];
    } catch (e) {
      throw Exception('Failed to get video paths: $e');
    }
  }

  Future<bool> hasLocalVideos() async {
    final paths = await getLocalVideoPaths();
    return paths.isNotEmpty;
  }
}