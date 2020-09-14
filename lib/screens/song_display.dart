import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/models/song_data.dart';
import '../components/song_item_widget.dart';

class SongDisplay extends StatelessWidget {
  static const String id = 'song_display';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          Container(
            padding:
                EdgeInsets.only(top: kSongToolbarHeight - kToolbarBorderRadius),
            child: ListView(children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: kToolbarBorderRadius + 8, left: 8, right: 8),
                  child: Text(
                    Provider.of<SongData>(context)
                        .songs[Provider.of<SongData>(context).activeSong]
                        .lyrics,
                    style: kSongLyricsTextStyle,
                  ),
                ),
              ),
            ]),
          ),
          SongToolbar(
            navigationIcon: Icons.arrow_back,
            onIconPressed: () {
              Navigator.pop(context);
            },
            childHeader: Center(
              child: SongItemWidget(
                  songItem: Provider.of<SongData>(context)
                      .songs[Provider.of<SongData>(context).activeSong]),
            ),
          ),
        ]),
      ),
    );
  }
}
