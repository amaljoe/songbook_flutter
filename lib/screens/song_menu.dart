import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/models/song_item.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import '../constants.dart';

class SongMenu extends StatelessWidget {
  static const String id = 'song_menu';
  @override
  Widget build(BuildContext context) {
    print('menu opened');
    if (context.select<SongData, List<SongItem>>((value) => value.songs) ==
        null) {
      print('load block entered');
      context.select<SongData, Future<void>>((value) => value.loadDatabase());
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
            onSearchPressed: () {
              Navigator.pushNamed(context, SongSearch.id);
            },
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
