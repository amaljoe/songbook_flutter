import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/models/song_item.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:provider/provider.dart';

class SongDisplayToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SongToolbar(
      navigationIcon: Icons.arrow_back,
      onIconPressed: () {
        Navigator.pop(context);
      },
      onSearchPressed: () {
        Navigator.pushNamed(context, SongSearch.id);
      },
      childHeader: Padding(
        padding: EdgeInsets.only(left: 20, top: 10),
        child: Center(
          child: SongItemWidget(
              songItem: context
                      .select<SongData, List<SongItem>>((value) => value.songs)[
                  context.select<SongData, int>((value) => value.activeSong)]),
        ),
      ),
    );
  }
}
