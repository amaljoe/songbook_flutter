import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import '../constants.dart';
import '../song_item.dart';
import '../songs_database.dart';

class SongListMenu extends StatefulWidget {
  @override
  _SongListMenuState createState() => _SongListMenuState();
}

class _SongListMenuState extends State<SongListMenu> {
  SongsDatabase songsDatabase = SongsDatabase();
  double topPadding;

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
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, i) {
                if (i == 0) {
                  topPadding = kToolbarBorderRadius;
                } else {
                  topPadding = 0;
                }
                return Padding(
                  padding: EdgeInsets.only(top: topPadding),
                  child: SongItemWidget(
                    songItem: snapshot.data[i],
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SongDisplay(songNum: i);
                        }),
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        });
  }
}
