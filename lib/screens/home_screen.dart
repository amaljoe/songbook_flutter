import 'package:flutter/material.dart';
import 'file:///J:/Workstation/AndroidStudioProjects/songbook_flutter/lib/utilities/constants.dart';
import 'package:songbook_flutter/screens/song_menu.dart';

import 'book_menu.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  int currentScreen = 0;
  Animation animation;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween<Offset>(begin: Offset.zero, end: Offset(0, 1)).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInSine));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentScreen,
        children: [
          SongMenu(onTap: () {
            Future.delayed(Duration(milliseconds: 200)).then((value) {
              animationController.forward();
            });
          }, onReturn: () {
            animationController.reverse(from: 1);
          }),
          BookMenu()
        ],
      ),
      extendBody: true,
      bottomNavigationBar: SlideTransition(
        position: animation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kBottomNavigationBarRadius),
              topRight: Radius.circular(kBottomNavigationBarRadius),
            ),
            boxShadow: [
              BoxShadow(spreadRadius: 0, color: Colors.black26, blurRadius: 6)
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kBottomNavigationBarRadius),
              topRight: Radius.circular(kBottomNavigationBarRadius),
            ),
            child: BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  currentScreen = index;
                });
              },
              currentIndex: currentScreen,
              items: [
                BottomNavigationBarItem(
                    title: Text('പാട്ടുപുസ്തകം '),
                    icon: Icon(Icons.library_music)),
                BottomNavigationBarItem(
                    title: Text('ആരാധനക്രമം'), icon: Icon(Icons.library_books))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
