import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import '../constants.dart';

class SongMenu extends StatefulWidget {
  static const String id = 'song_menu';

  @override
  _SongMenuState createState() => _SongMenuState();
}

class _SongMenuState extends State<SongMenu> with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController animation;
  bool allowNavigation = true;

  @override
  void initState() {
    super.initState();
    animation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 300), value: 1);
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
                  animation.forward();
                  animation.addStatusListener(
                    (status) {
                      if (status == AnimationStatus.completed &&
                          allowNavigation) {
                        allowNavigation = false;
                        Navigator.pushNamed(context, SongDisplay.id).then(
                          (value) {
                            allowNavigation = true;
                            animation.value = 0;
                            _controller.value = 0;
                            _controller.forward();
                          },
                        );
                      }
                    },
                  );
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
              child: Text(
                'Songbook',
                style: kHeaderTextStyle,
              ),
            ),
          ),
          ScaleTransition(
            scale: Tween<double>(begin: 0, end: 3).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeIn)),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeIn)),
              child: Container(
                height: MediaQuery.of(context).size.height,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
