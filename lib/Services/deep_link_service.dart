import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();
  final AppLinks _appLink = AppLinks();
  StreamSubscription<Uri>? _subscription;

  void initialize({required GlobalKey<NavigatorState> navigatorKey}) {
    ///----app opened from a link while closed
    _handleInitialLink(navigatorKey);

    ///----app opened from a link while app is running in bg
    _subscription = _appLink.uriLinkStream.listen(
      (uri) {
        _handleUri(uri, navigatorKey);
      },
      onError: (error) {
        debugPrint("Deep link error: $error");
      },
    );
  }

  Future<void> _handleInitialLink(
    GlobalKey<NavigatorState> navigatorKey,
  ) async {
    try{
      final Uri? uri=await _appLink.getInitialLink();
      if(uri!=null){
        _handleUri(uri, navigatorKey);
      }
    }
    catch(e){
      debugPrint("Initial deep link error: $e");
    }
  }
  void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey,){
    debugPrint("Received deep link: $uri");
    if(uri.scheme!="https")return;
    if(uri.host!="gentantrabackend-production.up.railway.app")return;
    if (uri.pathSegments.length < 2) return;
    if (uri.pathSegments[0] != "feed") return;
    if(uri.pathSegments.isEmpty) return;
    final String feedUuid = uri.pathSegments.first;
    debugPrint("Feed UUID received: $feedUuid");
    ///-------Navigation
  }
  void dispose(){
    _subscription?.cancel();
  }
}
