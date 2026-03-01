import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/settings_screen.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_search.dart';
class SongMenu extends StatelessWidget {
  static const String id = 'song_menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('പാട്ടു പുസ്തകം'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () =>
                Navigator.pushNamed(context, SongSearch.idFromHome),
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.id),
          ),
        ],
      ),
      body: SongListMenu(
        onPressed: (index) {
          context.read<SongData>().openSong(index);
          Navigator.pushNamed(context, SongDisplay.id);
        },
      ),
    );
  }
}
