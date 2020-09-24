import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/models/song_item.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import '../constants.dart';

class SongMenu extends StatefulWidget {
  static const String id = 'song_menu';

  @override
  _SongMenuState createState() => _SongMenuState();
}

class _SongMenuState extends State<SongMenu>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _controller.value = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            padding:
                EdgeInsets.only(top: kSongToolbarHeight - kToolbarBorderRadius),
            color: Colors.white,
            child: Container(
              color: Colors.white,
              child: SongListMenu(
                onPressed: (index) {
                  print(
                      'item ${context.read<SongData>().songs[index].songId - kStarting} pressed');
                  context.read<SongData>().openSong(
                      context.read<SongData>().songs[index].songId - kStarting);
                  Navigator.pushNamed(context, SongDisplay.id).then((value) {
                    _controller.value = 0;
                    _controller.forward();
                  });
                },
              ),
            ),
          ),
          SongToolbar(
            onSearchPressed: () {
              Navigator.pushNamed(context, SongSearch.idFromHome).then(
                (value) {
                  _controller.value = 0;
                  _controller.forward();
                },
              );
            },
            navigationIcon: AnimatedIcon(
              icon: AnimatedIcons.arrow_menu,
              progress: _controller,
            ),
            onIconPressed: () {},
            childHeader: Center(
              child: Hero(
                tag: 'title',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    'Songbook',
                    style: TextStyle(fontFamily: 'Pacifico', fontSize: 36),
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
