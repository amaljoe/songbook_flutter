import 'package:flutter/material.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/songs_database.dart';

import '../components/song_item_widget.dart';
import '../song_item.dart';
import '../song_item.dart';

class SongDisplay extends StatefulWidget {
  final int songNum;
  SongDisplay({this.songNum});
  @override
  _SongDisplayState createState() => _SongDisplayState();
}

class _SongDisplayState extends State<SongDisplay> {
  SongsDatabase songsDatabase = SongsDatabase();

  Future<List<SongItem>> getSongs() async {
    await songsDatabase.openSongsDatabase();
    return songsDatabase.getAllSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          FutureBuilder(
              future: getSongs(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.only(
                        top: kSongToolbarHeight - kToolbarBorderRadius),
                    color: Colors.green,
                    child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: kToolbarBorderRadius + 8, left: 8, right: 8),
                        child: Text(
                          snapshot.data[widget.songNum].lyrics,
                          style: kSongLyricsTextStyle,
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }),
          SongToolbar(
            navigationIcon: Icons.arrow_back,
            onIconPressed: () {
              Navigator.pop(context);
            },
            childHeader: Center(
              child: SongItemWidget(
                  songItem: SongItem(
                      title: 'നിന്‍റെ ഹിതം പോലെയെന്നെ നിത്യം നടത്തീടേണമേ',
                      songId: 258),
                  onPressed: () {}),
            ),
          ),
        ]),
      ),
    );
  }
}
