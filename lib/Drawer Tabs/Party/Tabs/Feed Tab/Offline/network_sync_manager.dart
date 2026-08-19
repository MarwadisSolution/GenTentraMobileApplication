import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gen_tentra_mobile_application/Drawer%20Tabs/Party/Tabs/Feed%20Tab/Offline/feed_sync_service.dart';

class NetworkSyncManager {
  NetworkSyncManager._();
  static final NetworkSyncManager instance=NetworkSyncManager._();

  StreamSubscription<List<ConnectivityResult>>?
  _subscription;
  void start(){

    _subscription??=
  Connectivity()
        .onConnectivityChanged
        .listen((results)async{
     if(results.hasConnectivity){
       await FeedSyncService.instance
           .syncPendingPosts();
     }
  });
  }
  Future<void>stop()async{
    await _subscription?.cancel();
    _subscription=null;
  }
}