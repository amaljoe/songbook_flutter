import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/models/song_item.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import '../constants.dart';

class SongListSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double topPadding;
    return ListView.builder(
      itemCount: context.select<SongData, List<SongItem>>(
                  (value) => value.searchSongs) ==
              null
          ? 0
          : context
              .select<SongData, List<SongItem>>((value) => value.searchSongs)
              .length,
      itemBuilder: (context, index) {
        if (index == 0) {
          topPadding = 10;
        } else {
          topPadding = 0;
        }
        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: GestureDetector(
            onTap: () {
              print(
                  'item ${context.read<SongData>().searchSongs[index].songId - kStarting} pressed');
              context.read<SongData>().openSong(
                  context.read<SongData>().searchSongs[index].songId -
                      kStarting);
              Navigator.pushNamedAndRemoveUntil(context, SongDisplay.id,
                  (Route<dynamic> route) => route.isFirst ? true : false);
              context.read<SongData>().clearSearch();
            },
            child: SongItemWidget(
              songItem: context.read<SongData>().searchSongs[index],
            ),
          ),
        );
      },
    );
  }
}
