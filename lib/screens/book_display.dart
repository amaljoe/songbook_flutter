import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/book_display_list.dart';
import 'package:songbook_flutter/components/song_title_header.dart';
import 'package:songbook_flutter/components/toolbar.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:wakelock/wakelock.dart';

class BookDisplay extends StatefulWidget {
  static const String id = 'book_display';
  @override
  _BookDisplayState createState() => _BookDisplayState();
}

class _BookDisplayState extends State<BookDisplay>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Tween<Offset> _tweenOffsetLyrics;
  Tween<Offset> _tweenOffsetToolbar;
  Animation<Offset> _offSetAnimationLyrics;
  Animation<Offset> _offSetAnimationToolbar;
  Curve _curve = ElasticOutCurve(0.7);

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _tweenOffsetLyrics = Tween<Offset>(begin: Offset(0.4, 0), end: Offset.zero);
    _tweenOffsetToolbar =
        Tween<Offset>(begin: Offset(0, -0.7), end: Offset.zero);
    _offSetAnimationLyrics = _tweenOffsetLyrics
        .animate(CurvedAnimation(parent: _animationController, curve: _curve));
    _offSetAnimationToolbar = _tweenOffsetToolbar
        .animate(CurvedAnimation(parent: _animationController, curve: _curve));
    _animationController.forward();
  }

  @override
  void deactivate() {
    super.deactivate();
    Wakelock.disable();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          SlideTransition(
            position: _offSetAnimationLyrics,
            child: BookDisplayList(),
          ),
          SlideTransition(
            position: _offSetAnimationToolbar,
            child: Toolbar(
              type: ToolbarType.book,
              navigationIcon: Icon(Icons.arrow_back),
              onIconPressed: () {
                Navigator.pop(context);
              },
              onSearchPressed: () {
                Navigator.pushNamed(context, SongSearch.id).then((newSong) {
                  if (newSong != null && newSong) {
                    _animationController.value = 0;
                    _animationController.forward();
                  }
                });
              },
              childHeader: null,
            ),
          ),
        ]),
      ),
    );
  }
}
