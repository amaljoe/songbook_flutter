import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/models/song_data.dart';
import '../constants.dart';

class SongListMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double topPadding;
    return ListView.builder(
      itemCount: context.select<SongData, int>((value) => value.songs.length),
      itemBuilder: (context, index) {
        if (index == 0) {
          topPadding = kToolbarBorderRadius;
        } else {
          topPadding = 0;
        }
        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: GestureDetector(
            onTap: () {
              print('list pressed');
              context.read<SongData>().openSong(index);
              Navigator.pushNamed(context, SongDisplay.id);
            },
            child: SongItemWidget(
              songItem: context.read<SongData>().songs[index],
            ),
          ),
        );
      },
    );
  }
}
