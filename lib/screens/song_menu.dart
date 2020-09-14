import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';

import '../constants.dart';

class SongMenu extends StatelessWidget {
  static const String id = 'song_menu';
  @override
  Widget build(BuildContext context) {
    print('menu opened');
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
              child: Hero(
                tag: 'appTitle',
                child: Text(
                  'Songbook',
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
