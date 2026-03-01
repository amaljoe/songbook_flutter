import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_search.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class SongSearch extends StatelessWidget {
  final bool fromHome;
  static const String idFromHome = 'song_search_home';
  static const String id = 'song_search';

  SongSearch({required this.fromHome});

  void _gotoSong(BuildContext context, int songId) {
    final index = songId - kStarting;
    context.read<SongData>().openSong(index);
    if (fromHome) {
      Navigator.pushReplacementNamed(context, SongDisplay.id);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search by title or number',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            if (int.tryParse(text) != null && text.length == 3) {
              _gotoSong(context, int.parse(text));
            } else {
              context.read<SongData>().search(text);
            }
          },
        ),
      ),
      body: SongListSearch(
        onPressed: (index) {
          _gotoSong(
            context,
            context.read<SongData>().searchSongs[index].songId,
          );
        },
      ),
    );
  }
}
