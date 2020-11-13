import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/screens/book_display.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_menu.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:songbook_flutter/screens/welcome_screen.dart';
import 'models/song_data.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SongData>(create: (_) => SongData()),
        ChangeNotifierProvider<BookData>(create: (_) => BookData()),
      ],
      child: MyApp(),
    ),
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
          case HomeScreen.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return HomeScreen();
              },
              transitionDuration: Duration(milliseconds: 800),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity:
                      CurvedAnimation(parent: animation, curve: Curves.ease),
                  child: child,
                );
              },
            );
          case SongDisplay.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongDisplay();
              },
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                switch (animation.status) {
                  case AnimationStatus.forward:
                    return FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                                parent: animation, curve: Curves.easeOutCubic)),
                        child: child);
                  case AnimationStatus.reverse:
                    return SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                              .animate(CurvedAnimation(
                                  parent: animation, curve: Curves.ease)),
                      child: child,
                    );
                  default:
                    return child;
                }
              },
            );
          case BookDisplay.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return BookDisplay();
              },
              transitionDuration: Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                switch (animation.status) {
                  case AnimationStatus.forward:
                    return FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                            CurvedAnimation(
                                parent: animation, curve: Curves.easeOutCubic)),
                        child: child);
                  case AnimationStatus.reverse:
                    return SlideTransition(
                      position:
                          Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                              .animate(CurvedAnimation(
                                  parent: animation, curve: Curves.ease)),
                      child: child,
                    );
                  default:
                    return child;
                }
              },
            );
          case WelcomeScreen.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return WelcomeScreen();
              },
            );
          case SongMenu.id:
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) {
                return SongMenu();
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
                return WelcomeScreen();
              },
              transitionDuration: Duration(seconds: 0),
              transitionsBuilder: (_, animation, __, child) => child,
            );
        }
      },
    );
  }
}
