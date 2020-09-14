import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:songbook_flutter/screens/loading_screen.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_menu.dart';
import 'package:provider/provider.dart';
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
      initialRoute: Provider.of<SongData>(context).songsLoaded
          ? SongMenu.id
          : LoadingScreen.id,
      theme: ThemeData.light(),
      routes: {
        LoadingScreen.id: (context) => LoadingScreen(context: context),
        SongMenu.id: (context) => SongMenu(),
        SongDisplay.id: (context) => SongDisplay(),
      },
    );
  }
}
