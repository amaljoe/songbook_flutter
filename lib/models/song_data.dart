import 'package:flutter/foundation.dart';
import 'package:songbook_flutter/songs_database.dart';
import 'song_item.dart';
import 'package:string_validator/string_validator.dart';

class SongData extends ChangeNotifier {
  int activeSong;
  List<SongItem> songs;
  List<SongItem> searchSongs;
  SongsDatabase songsDatabase = SongsDatabase();

  //will
  void search(String searchText) async {
    if (isNumeric(searchText)) {
      searchSongs = await songsDatabase.getSearchSongsByNum(searchText);
    } else {
      searchSongs = await songsDatabase.getSearchSongs(searchText);
    }
    print('search songs loaded');
    notifyListeners();
  }

  void openSong(int songNum) {
    activeSong = songNum;
    notifyListeners();
  }

  void clearSearch() {
    searchSongs = [];
    notifyListeners();
  }

  Future<void> loadDatabase() async {
    await songsDatabase.openSongsDatabase();
    songs = await songsDatabase.getAllSongs();
    print('songs loaded');
    notifyListeners();
  }
}
