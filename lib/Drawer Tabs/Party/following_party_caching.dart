import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FollowingPartyCaching {
  static const String _key = "following_party_ids";

  Future<void> saveFollowingIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(ids));
  }

  Future<List<int>> getFollowingIds() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_key);

    if (data == null) return [];

    return List<int>.from(jsonDecode(data));
  }

  Future<bool> isFollowing(int id) async {
    final ids = await getFollowingIds();
    return ids.contains(id);
  }

  Future<void> addFollowing(int id) async {
    final ids = await getFollowingIds();

    if (!ids.contains(id)) {
      ids.add(id);
      await saveFollowingIds(ids);
    }
  }

  Future<void> removeFollowing(int id) async {
    final ids = await getFollowingIds();

    ids.remove(id);

    await saveFollowingIds(ids);
  }
}