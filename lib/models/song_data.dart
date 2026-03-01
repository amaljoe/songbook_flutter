import 'package:flutter/foundation.dart';
import 'package:songbook_flutter/utilities/songs_database.dart';
import 'song_item.dart';

//provider class for dealing with songs
class SongData extends ChangeNotifier {
  int? activeSong;
  List<SongItem>? songs;
  List<SongItem> searchSongs = [];
  late SongsDatabase songsDatabase;

  SongData() {
    songsDatabase = SongsDatabase();
  }

  //searches for a song title on database
  void search(String searchText) async {
    if (int.tryParse(searchText) != null) {
      searchSongs = await songsDatabase.getSearchSongsByNum(searchText);
    } else {
      searchSongs = await songsDatabase.getSearchSongs(searchText);
    }
    notifyListeners();
  }

  //set a song as active which can be opened in song display
  void openSong(int songNum) {
    activeSong = songNum;
    notifyListeners();
  }

  //clear search results especially after a search is completed or abandoned halfway
  void clearSearch() {
    searchSongs = [];
    notifyListeners();
  }

  //load songs database into memory
  Future<void> loadDatabase() async {
    await songsDatabase.openSongsDatabase();
    songs = await songsDatabase.getAllSongs();
    notifyListeners();
  }
}
