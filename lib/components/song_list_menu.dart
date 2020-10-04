import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/models/song_data.dart';
import '../constants.dart';

class SongListMenu extends StatelessWidget {
  final Function onPressed;

  SongListMenu({@required this.onPressed});

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
              onPressed(index);
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
