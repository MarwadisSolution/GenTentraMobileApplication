import 'dart:convert';
import 'dart:io';

import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/Offline/offline_feed_database.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<List<String>> persistMediaFiles(List<File> mediaFiles) async {
  if (mediaFiles.isEmpty) {
    return [];
  }

  final appDir = await getApplicationDocumentsDirectory();

  final offlineMediaDir = Directory(
    path.join(appDir.path, 'offline_feed_media'),
  );

  if (!await offlineMediaDir.exists()) {
    await offlineMediaDir.create(recursive: true);
  }

  final List<String> savedPaths = [];

  for (final file in mediaFiles) {
    if (!await file.exists()) {
      throw Exception(
        'Media file does not exist: ${file.path}',
      );
    }

    final fileName =
        '${DateTime.now().microsecondsSinceEpoch}_${path.basename(file.path)}';

    final destination = path.join(
      offlineMediaDir.path,
      fileName,
    );

    final copiedFile = await file.copy(destination);

    savedPaths.add(copiedFile.path);
  }

  return savedPaths;
}

class OfflineFeedRepository {
  final OfflineFeedDatabase database = OfflineFeedDatabase.instance;

  Future<int> savePost({
    required FeedModel feed,
    required List<File>mediaFiles,
  }) async {
    final mediaPaths = await persistMediaFiles(mediaFiles);

    return database.insertPendingPost(
        payload: feed.toJson(), mediaPaths: mediaPaths
    );
  }
  Future<List<Map<String,dynamic>>>getPendingPosts(){
    return database.getPendingPosts();
  }
  Map<String, dynamic> decodePayloads(String payload){
    return jsonDecode(payload);
  }
  List<String>decodeMediaPaths(String paths){
    final result = jsonDecode(paths);
    return List<String>.from(result);
  }
  Future<void>deletePost(int id){
    return database.deletePost(id);
  }
  Future<void>incrementRetryCount(int id){
    return database.incrementRetryCount(id);
  }
}