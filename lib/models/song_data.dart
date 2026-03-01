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

  bool _isMalayalam(String text) =>
      text.runes.any((r) => r >= 0x0D00 && r <= 0x0D7F);

  // Collapses common Manglish phoneme variants so that e.g.
  // "entho" and "ento" both normalize to the same form.
  String _normalizeManglish(String s) {
    s = s.toLowerCase().trim();
    // Longer digraphs first to avoid partial replacement
    s = s.replaceAll('th', 't');
    s = s.replaceAll('sh', 's');
    s = s.replaceAll('kh', 'k');
    s = s.replaceAll('gh', 'g');
    s = s.replaceAll('ph', 'p');
    s = s.replaceAll('zh', 'l');
    s = s.replaceAll('ck', 'k');
    // Long vowels → short equivalents
    s = s.replaceAll('aa', 'a');
    s = s.replaceAll('ee', 'e');
    s = s.replaceAll('oo', 'o');
    return s;
  }

  // Searches in-memory: number prefix, Malayalam substring, or Manglish fuzzy
  void search(String searchText) {
    if (searchText.isEmpty || songs == null) {
      searchSongs = [];
      notifyListeners();
      return;
    }
    if (int.tryParse(searchText) != null) {
      // Number prefix match on songId
      searchSongs = songs!
          .where((s) => s.songId.toString().startsWith(searchText))
          .toList();
    } else if (_isMalayalam(searchText)) {
      // Direct Malayalam substring match on title
      searchSongs = songs!.where((s) => s.title.contains(searchText)).toList();
    } else {
      // Manglish fuzzy: normalize both sides then substring match
      final norm = _normalizeManglish(searchText);
      searchSongs = songs!
          .where((s) => _normalizeManglish(s.titleEng).contains(norm))
          .toList();
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
