import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/models/song_data.dart';

import '../constants.dart';

class SongMenu extends StatelessWidget {
  static const String id = 'song_menu';
  @override
  Widget build(BuildContext context) {
    print('menu opened');
    if (!Provider.of<SongData>(context).songsLoaded) {
      Provider.of<SongData>(context).loadDatabase();
      return Scaffold(
        body: Container(
          child: Center(
            child: Text(
              'Songbook',
              style: kHeaderTextStyle,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            padding:
                EdgeInsets.only(top: kSongToolbarHeight - kToolbarBorderRadius),
            color: Colors.green,
            child: Container(
              color: Colors.white,
              child: SongListMenu(),
            ),
          ),
          SongToolbar(
            navigationIcon: Icons.menu,
            onIconPressed: () {},
            childHeader: Center(
              child: Text(
                'Songbook',
                style: kHeaderTextStyle,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
