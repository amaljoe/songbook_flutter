import 'package:flutter/material.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_menu.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/screens/song_search.dart';
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
      initialRoute: SongMenu.id,
      theme: ThemeData.light(),
      onGenerateRoute: (settings) {
        if (settings.name == SongDisplay.id) {
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) {
              return SongDisplay();
            },
            transitionDuration: Duration(seconds: 0),
            transitionsBuilder: (_, animation, __, child) {
              var begin = Offset(0.0, 1.0);
              var end = Offset.zero;
              var curve = Curves.ease;

              var tween = Tween(begin: begin, end: end);
              var curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: curve,
              );

              return child;
            },
          );
        }
        return null;
      },
      routes: {
        SongMenu.id: (context) => SongMenu(),
        SongSearch.id: (context) => SongSearch(),
      },
    );
  }
}
