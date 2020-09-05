import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/song_item.dart';
import 'package:songbook_flutter/song_item_manager.dart';

class SongMenu extends StatefulWidget {
  @override
  _SongMenuState createState() => _SongMenuState();
}

class _SongMenuState extends State<SongMenu> {
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
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                    top: kToolbarBorderRadius, left: 4, right: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SongItemWidget(
                      songItem: songItemManager.getSong(1),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return SongDisplay(songNum: 1);
                          }),
                        );
                      },
                    ),
                    SongItemWidget(
                      songItem: songItemManager.getSong(2),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return SongDisplay(songNum: 2);
                          }),
                        );
                      },
                    ),
                    SongItemWidget(
                      songItem: songItemManager.getSong(3),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return SongDisplay(songNum: 3);
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SongToolbar(
            navigationIcon: Icons.menu,
            onIconPressed: () {},
          ),
        ]),
      ),
    );
  }
}
