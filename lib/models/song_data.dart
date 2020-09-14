import 'package:flutter/cupertino.dart';
import 'file:///C:/Users/amalj/AndroidStudioProjects/songbook_flutter/lib/models/song_item.dart';
import 'package:songbook_flutter/songs_database.dart';

class SongData extends ChangeNotifier {
  int activeSong;
  bool songsLoaded = false;
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
    songsLoaded = true;
    notifyListeners();
  }
}
