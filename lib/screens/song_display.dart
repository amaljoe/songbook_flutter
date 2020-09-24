import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_display_pager.dart';
import 'package:songbook_flutter/components/song_title_header.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:wakelock/wakelock.dart';

class SongDisplay extends StatefulWidget {
  static const String id = 'song_display/';

  @override
  _SongDisplayState createState() => _SongDisplayState();
}

class _SongDisplayState extends State<SongDisplay>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Tween<double> _tweenOpacity;
  Animation<double> _opacityAnimation;
  Tween<Offset> _tweenOffsetLyrics;
  Animation<Offset> _offSetAnimationLyrics;
  Animation<Offset> _offSetAnimationToolbar;
  Curve _curve = Curves.easeOutCubic;
  @override
  void initState() {
    print('enabling wakelock and animation controllers');
    super.initState();
    Wakelock.enable();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _tweenOpacity = Tween<double>(begin: 0, end: 1);
    _tweenOffsetLyrics = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero);
    _offSetAnimationLyrics = _tweenOffsetLyrics
        .animate(CurvedAnimation(parent: _animationController, curve: _curve));
    _opacityAnimation = _tweenOpacity.animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutExpo));
    _animationController.forward();
  }

  @override
  void deactivate() {
    super.deactivate();
    Wakelock.disable();
    print('wakelock disabled');
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    print('animation disposed');
  }

  @override
  Widget build(BuildContext context) {
    print('entering build of display');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          SlideTransition(
            position: _offSetAnimationLyrics,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: SongDisplayPager(),
            ),
          ),
          SongToolbar(
            navigationIcon: Icons.arrow_back,
            onIconPressed: () {
              Navigator.pop(context);
            },
            onSearchPressed: () {
              Navigator.pushNamed(context, SongSearch.id);
            },
            childHeader: SongTitleHeader(),
          ),
        ]),
      ),
    );
  }
}
