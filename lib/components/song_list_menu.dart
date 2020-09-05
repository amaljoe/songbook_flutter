import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import '../constants.dart';
import '../song_item.dart';
import '../song_item_manager.dart';
import '../songs_database.dart';

class SongListMenu extends StatefulWidget {
  @override
  _SongListMenuState createState() => _SongListMenuState();
}

class _SongListMenuState extends State<SongListMenu> {
  SongItemManager songItemManager = SongItemManager();
  SongsDatabase songsDatabase = SongsDatabase();
  List<SongItem> songs;

  Future<List<SongItem>> getSongs() async {
    await songsDatabase.openSongsDatabase();
    return songsDatabase.getAllSongs();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSongs(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
                padding: EdgeInsets.only(
                    top: kToolbarBorderRadius, left: 4, right: 4),
                child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, i) {
                    return SongItemWidget(
                      songItem: snapshot.data[i],
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return SongDisplay(songNum: i);
                          }),
                        );
                      },
                    );
                  },
                ));
          } else {
            return Container();
          }
        });
  }
}

// Column(
// mainAxisSize: MainAxisSize.max,
// children: [
// SongItemWidget(
// songItem: snapshot.data[0],
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) {
// return SongDisplay(songNum: 1);
// }),
// );
// },
// ),
// SongItemWidget(
// songItem: snapshot.data[1],
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) {
// return SongDisplay(songNum: 2);
// }),
// );
// },
// ),
// SongItemWidget(
// songItem: snapshot.data[2],
// onPressed: () {
// Navigator.push(
// context,
// MaterialPageRoute(builder: (context) {
// return SongDisplay(songNum: 3);
// }),
// );
// },
// ),
// ],
// ),
