import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook_flutter/models/song_item.dart';

class SearchHistoryData extends ChangeNotifier {
  static const _keyRecentSearches = 'recentSearches';
  static const _keySongOpenCounts = 'songOpenCounts';

  List<String> recentSearches = [];
  Map<int, int> songOpenCounts = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches = prefs.getStringList(_keyRecentSearches) ?? [];
    final raw = prefs.getString(_keySongOpenCounts) ?? '{}';
    final map = jsonDecode(raw) as Map<String, dynamic>;
    songOpenCounts = map.map((k, v) => MapEntry(int.parse(k), v as int));
    notifyListeners();
  }

  Future<void> addSearch(String query) async {
    query = query.trim();
    if (query.isEmpty) return;
    recentSearches.removeWhere((s) => s == query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 3) recentSearches = recentSearches.sublist(0, 3);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRecentSearches, recentSearches);
    notifyListeners();
  }

  Future<void> recordOpen(int songId) async {
    songOpenCounts[songId] = (songOpenCounts[songId] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keySongOpenCounts,
      jsonEncode(songOpenCounts.map((k, v) => MapEntry(k.toString(), v))),
    );
    notifyListeners();
  }

  List<SongItem> topSongs(List<SongItem> allSongs, {int limit = 5}) {
    if (songOpenCounts.isEmpty) return [];
    final sorted = allSongs
        .where((s) => songOpenCounts.containsKey(s.songId))
        .toList()
      ..sort((a, b) =>
          (songOpenCounts[b.songId] ?? 0).compareTo(songOpenCounts[a.songId] ?? 0));
    return sorted.take(limit).toList();
  }
}
