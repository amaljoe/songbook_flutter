import 'package:flutter/foundation.dart';
import 'package:songbook_flutter/utilities/songs_database.dart';
import 'song_item.dart';
import 'package:string_validator/string_validator.dart';

//provider class for dealing with songs
class SongData extends ChangeNotifier {
  int activeSong;
  List<SongItem> songs;
  List<SongItem> searchSongs;
  SongsDatabase songsDatabase;

  SongData() {
    songsDatabase = SongsDatabase();
  }

  //searches for a song title on database
  void search(String searchText) async {
    if (isNumeric(searchText)) {
      searchSongs = await songsDatabase.getSearchSongsByNum(searchText);
    } else {
      searchSongs = await songsDatabase.getSearchSongs(searchText);
    }
    print('search songs loaded');
    notifyListeners();
  }

  //set a song as active which can be opened in song display
  void openSong(int songNum) {
    activeSong = songNum;
    notifyListeners();
  }

  //clear search results especially after a search is completed or abandoned halfway
  void clearSearch() {
    print('clearing search');
    searchSongs = [];
    notifyListeners();
  }

  //load songs database into memory
  Future<void> loadDatabase() async {
    await songsDatabase.openSongsDatabase();
    songs = await songsDatabase.getAllSongs();
    print('songs loaded');
    notifyListeners();
  }
}
