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
  final Function onTap;
  final Function onReturn;

  SongMenu({this.onTap, this.onReturn});

  @override
  _SongMenuState createState() => _SongMenuState();
}

class _SongMenuState extends State<SongMenu> with TickerProviderStateMixin {
  AnimationController _navController;
  AnimationController animation;
  bool allowNavigation = true;

  @override
  void initState() {
    super.initState();
    print('entering init of menu');
    animation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _navController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 300), value: 1);
  }

  @override
  void deactivate() {
    super.deactivate();
    print('entering deactivate of menu');
  }

  @override
  void dispose() {
    super.dispose();
    print('entering dispose of menu');
    _navController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
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
                  widget.onTap();
                  animation.forward();
                  animation.addStatusListener(
                    (status) async {
                      if (status == AnimationStatus.completed &&
                          allowNavigation) {
                        allowNavigation = false;
                        await Navigator.pushNamed(context, SongDisplay.id);
                        widget.onReturn();
                        print('menu animation restored');
                        allowNavigation = true;
                        animation.value = 0;
                        _navController.value = 0;
                        _navController.forward();
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
                  _navController.value = 0;
                  _navController.forward();
                },
              );
            },
            navigationIcon: AnimatedIcon(
              icon: AnimatedIcons.arrow_menu,
              progress: _navController,
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
            scale: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.ease)),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.ease)),
              child: Transform.scale(
                scale: 2.5,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
