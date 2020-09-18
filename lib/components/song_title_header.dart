import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/models/song_item.dart';
import 'package:provider/provider.dart';

class SongTitleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 10),
      child: Center(
        child: SongItemWidget(
            songItem: context
                    .select<SongData, List<SongItem>>((value) => value.songs)[
                context.select<SongData, int>((value) => value.activeSong)]),
      ),
    );
  }
}
