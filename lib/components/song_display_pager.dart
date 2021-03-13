import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class SongDisplayPager extends StatefulWidget {
  @override
  _SongDisplayPagerState createState() => _SongDisplayPagerState();
}

class _SongDisplayPagerState extends State<SongDisplayPager> {
  PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      keepPage: false,
      initialPage: context.read<SongData>().activeSong,
    );
  }

  @override
  Widget build(BuildContext context) {
    int songNum = context.read<SongData>().activeSong;
    if (_controller.hasClients && _controller.page != songNum) {
      _controller.jumpToPage(songNum);
    }
    return PageView.builder(
        onPageChanged: (index) {
          print('index number: $index');
          context.read<SongData>().openSong(index);
        },
        controller: _controller,
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
