import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_display_toolbar.dart';
import 'package:songbook_flutter/components/song_display_pager.dart';

class SongDisplay extends StatefulWidget {
  static const String id = 'song_display';

  @override
  _SongDisplayState createState() => _SongDisplayState();
}

class _SongDisplayState extends State<SongDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          SongDisplayPager(),
          SongDisplayToolbar(),
        ]),
      ),
    );
  }
}
