import 'package:flutter/material.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/song_item_manager.dart';

class SongDisplay extends StatefulWidget {
  final int songNum;
  SongDisplay({this.songNum});
  @override
  _SongDisplayState createState() => _SongDisplayState();
}

class _SongDisplayState extends State<SongDisplay> {
  SongItemManager songItemManager = SongItemManager();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            padding:
                EdgeInsets.only(top: kSongToolbarHeight - kToolbarBorderRadius),
            color: Colors.green,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                    top: kToolbarBorderRadius + 8, left: 8, right: 8),
                child: Text(
                  songItemManager.getSong(widget.songNum).lyrics,
                  style: kSongLyricsTextStyle,
                ),
              ),
            ),
          ),
          SongToolbar(
            navigationIcon: Icons.arrow_back,
            onIconPressed: () {
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }
}
