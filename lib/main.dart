import 'package:flutter/material.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_menu.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:songbook_flutter/screens/welcome_screen.dart';
import 'models/song_data.dart';

void main() {
  runApp(
    ChangeNotifierProvider<SongData>(
        create: (context) => SongData(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      theme: ThemeData.light(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SongDisplay.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongDisplay();
              },
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder: (_, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.ease)),
                  child: FadeTransition(
                      opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                              parent: animation, curve: Curves.easeInExpo)),
                      child: child),
                );
              },
            );
          case WelcomeScreen.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return WelcomeScreen();
              },
              transitionDuration: Duration(seconds: 0),
              transitionsBuilder: (_, animation, __, child) => child,
            );
          case SongMenu.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongMenu();
              },
              transitionDuration: Duration(milliseconds: 500),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity:
                      CurvedAnimation(parent: animation, curve: Curves.ease),
                  child: child,
                );
              },
            );
          case SongSearch.idFromHome:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongSearch(
                  fromHome: true,
                );
              },
              transitionDuration: Duration(seconds: 0),
              transitionsBuilder: (_, animation, __, child) => child,
            );
          case SongSearch.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongSearch(
                  fromHome: false,
                );
              },
              transitionDuration: Duration(seconds: 0),
              transitionsBuilder: (_, animation, __, child) => child,
            );
          default:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongMenu();
              },
              transitionDuration: Duration(seconds: 0),
              transitionsBuilder: (_, animation, __, child) => child,
            );
        }
      },
    );
  }
}
