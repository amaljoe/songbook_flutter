import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class BookMenu extends StatefulWidget {
  static const String id = 'song_menu';

  @override
  _BookMenuState createState() => _BookMenuState();
}

class _BookMenuState extends State<BookMenu> with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController animation;
  bool allowNavigation = true;

  @override
  void initState() {
    super.initState();
    print('entering init of menu');
    animation =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));
    _controller = AnimationController(
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
    _controller.dispose();
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
              child: Center(
                child: Text(
                  'Coming Soon',
                  style: kWelcomeHeaderTextStyle.copyWith(color: Colors.red),
                ),
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
              child: Container(),
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
