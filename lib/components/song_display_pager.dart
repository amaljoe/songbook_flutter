import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class SongDisplayPager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
        onPageChanged: (index) {
          print('actually $index');
          context.read<SongData>().openSong(index);
        },
        controller: PageController(
            initialPage:
                context.select<SongData, int>((value) => value.activeSong)),
        itemCount: context.select<SongData, int>((value) => value.songs.length),
        itemBuilder: (context, index) {
          return Container(
            padding:
                EdgeInsets.only(top: kSongToolbarHeight - kToolbarBorderRadius),
            child: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: kToolbarBorderRadius + 8, left: 16, right: 16),
                    child: Text(
                      context.read<SongData>().songs[index].lyrics,
                      style: kSongLyricsTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
