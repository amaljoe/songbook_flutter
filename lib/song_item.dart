import 'package:flutter/cupertino.dart';

class SongItem {
  final String lyrics;
  final String title;
  final String titleEng;
  final int num;

  SongItem(
      {@required this.lyrics,
      @required this.title,
      @required this.titleEng,
      @required this.num});
}
