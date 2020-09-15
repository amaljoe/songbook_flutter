import 'package:flutter/foundation.dart';
import 'package:songbook_flutter/songs_database.dart';
import 'song_item.dart';

class SongData extends ChangeNotifier {
  int activeSong;
  List<SongItem> songs;

  void openSong(int songNum) {
    activeSong = songNum;
    notifyListeners();
  }

  Future<void> loadDatabase() async {
    SongsDatabase songsDatabase = SongsDatabase();
    await songsDatabase.openSongsDatabase();
    songs = await songsDatabase.getAllSongs();
    print('songs loaded');
    notifyListeners();
  }
}
