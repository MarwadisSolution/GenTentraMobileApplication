import 'dart:ffi';
import 'dart:io';

import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/Offline/offline_feed_repository.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/apis.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/feed_model.dart';
class FeedSyncService {
  FeedSyncService._();
  static final FeedSyncService instance= FeedSyncService._();
  final FeedApis feedApis=FeedApis();
  final OfflineFeedRepository repository=OfflineFeedRepository();
  bool _isSyncing=false;
  Future<void>syncPendingPosts()async{
    if(_isSyncing)return;
    _isSyncing=true;
    try {
      final connectivity=await Connectivity().checkConnectivity();
      if(!connectivity.hasConnectivity)return;
      final posts=await repository.getPendingPosts();
      for(final post in posts){
        try{
          final payload=repository.decodePayloads(post['payload']);
          final mediaPaths=repository.decodeMediaPaths(post['media_paths'],
          );
          final mediaFiles=<File>[];
          for(final path in mediaPaths){
            final file=File(path);
            if(await file.exists()){
              mediaFiles.add(file);
            }
          }
          final feed=FeedModel.fromJson(payload);
          await feedApis.postTheFeed(feed: feed,
              mediaFiles: mediaFiles
          );
          await repository.deletePost(post['id'] as int);
        }

            catch(e){
          await repository.incrementRetryCount(
            post['id'] as int,
          );
          break;
            }
      }
    }
    finally{
      _isSyncing=false;
    }

  }
}