import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/book_display_list.dart';
import 'package:songbook_flutter/components/toolbar.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BookDisplay extends StatefulWidget {
  static const String id = 'book_display';

  @override
  _BookDisplayState createState() => _BookDisplayState();
}

class _BookDisplayState extends State<BookDisplay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Tween<Offset> _tweenOffsetLyrics;
  late Tween<Offset> _tweenOffsetToolbar;
  late Animation<Offset> _offSetAnimationLyrics;
  late Animation<Offset> _offSetAnimationToolbar;
  final Curve _curve = ElasticOutCurve(0.7);

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _tweenOffsetLyrics = Tween<Offset>(begin: Offset(0.4, 0), end: Offset.zero);
    _tweenOffsetToolbar =
        Tween<Offset>(begin: Offset(0, -0.7), end: Offset.zero);
    _offSetAnimationLyrics = _tweenOffsetLyrics.animate(
        CurvedAnimation(parent: _animationController, curve: _curve));
    _offSetAnimationToolbar = _tweenOffsetToolbar.animate(
        CurvedAnimation(parent: _animationController, curve: _curve));
    _animationController.forward();
  }

  @override
  void deactivate() {
    super.deactivate();
    WakelockPlus.disable();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = context.watch<BookData>().pages;
    final activePage = context.watch<BookData>().activePage;
    final title = (pages != null && activePage != null)
        ? pages[activePage].title
        : '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade50,
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
                onSearchPressed: () {},
                childHeader: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
