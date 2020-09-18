import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_display_pager.dart';
import 'package:songbook_flutter/components/song_title_header.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/screens/song_search.dart';

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
  Tween<Offset> _tweenOffsetHorizontal;
  Tween<Offset> _tweenOffsetVertical;
  Animation<Offset> _offSetAnimationHorizontal;
  Animation<Offset> _offSetAnimationVertical;
  @override
  void initState() {
    print('entering init of display');
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _tweenOpacity = Tween<double>(begin: 0, end: 1);
    _tweenOffsetHorizontal =
        Tween<Offset>(begin: Offset(0.2, 0), end: Offset.zero);
    _tweenOffsetVertical =
        Tween<Offset>(begin: Offset(0, -0.2), end: Offset.zero);
    _offSetAnimationHorizontal = _tweenOffsetHorizontal.animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _offSetAnimationVertical = _tweenOffsetVertical.animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _opacityAnimation = _tweenOpacity.animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastLinearToSlowEaseIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('entering build of display');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          SlideTransition(
            position: _offSetAnimationHorizontal,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: SongDisplayPager(),
            ),
          ),
          SlideTransition(
              position: _offSetAnimationVertical,
              child: SongToolbar(
                navigationIcon: Icons.arrow_back,
                onIconPressed: () {
                  Navigator.pop(context);
                },
                onSearchPressed: () {
                  Navigator.pushNamed(context, SongSearch.id);
                },
                childHeader: SongTitleHeader(),
              )),
        ]),
      ),
    );
  }
}
