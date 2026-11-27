import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Reusable Functions/reusable_functions.dart' show api;

class CivicPortrait extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CivicPortrait(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final base = Uri.parse(api);
    final uri = base.resolve(path.trim());
    final blank = SizedBox(width: width, height: height);
    if (!uri.isScheme('https') && !uri.isScheme('http')) return blank;

    Widget portrait(Map<String, String>? headers) => CachedNetworkImage(
      imageUrl: uri.toString(),
      httpHeaders: headers,
      width: width,
      height: height,
      fit: fit,
      errorWidget: (_, _, _) => blank,
    );

    if (uri.origin != base.origin) return portrait(null);
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return blank;
        final token = snapshot.data!.getString('accessToken');
        return portrait(
          token == null ? null : {'Authorization': 'Bearer $token'},
        );
      },
    );
  }
}
