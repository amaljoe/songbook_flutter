import 'package:flutter/material.dart';
import 'package:songbook_flutter/screens/song_menu.dart';

import 'book_menu.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentScreen,
        children: [SongMenu(), BookMenu()],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(spreadRadius: 0, color: Colors.black38, blurRadius: 10)
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
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
                  title: Text('Songs'), icon: Icon(Icons.library_music)),
              BottomNavigationBarItem(
                  title: Text('Books'), icon: Icon(Icons.library_books))
            ],
          ),
        ),
      ),
    );
  }
}
