import 'package:flutter/cupertino.dart';

class SongItem {
  final int songId;
  final String title;
  final String titleEng;
  final String lyrics;

  SongItem({
    @required this.songId,
    @required this.title,
    @required this.titleEng,
    @required this.lyrics,
  });

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'title': title,
      'titleEng': titleEng,
      'lyrics': lyrics,
    };
  }
}
