import 'package:flutter/foundation.dart';
import 'package:songbook_flutter/songs_database.dart';
import 'song_item.dart';

class SongData extends ChangeNotifier {
  int activeSong;
  List<SongItem> songs;
  List<SongItem> searchSongs;
  SongsDatabase songsDatabase = SongsDatabase();

  void search(String searchText) async {
    searchSongs = await songsDatabase.getSearchSongs(searchText);
    print('search songs loaded');
    notifyListeners();
  }

  void openSong(int songNum) {
    activeSong = songNum;
    notifyListeners();
  }

  Future<void> loadDatabase() async {
    await songsDatabase.openSongsDatabase();
    songs = await songsDatabase.getAllSongs();
    print('songs loaded');
    notifyListeners();
  }
}
