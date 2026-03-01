import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class SongDisplayPager extends StatefulWidget {
  @override
  _SongDisplayPagerState createState() => _SongDisplayPagerState();
}

class _SongDisplayPagerState extends State<SongDisplayPager> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      keepPage: false,
      initialPage: context.read<SongData>().activeSong ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    int songNum = context.read<SongData>().activeSong ?? 0;
    if (_controller.hasClients && _controller.page != songNum) {
      _controller.jumpToPage(songNum);
    }
    return PageView.builder(
        onPageChanged: (index) {
          context.read<SongData>().openSong(index);
        },
        controller: _controller,
        itemCount: context.select<SongData, int>((value) => value.songs?.length ?? 0),
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
                        top: kToolbarBorderRadius + 8, left: 8, right: 8),
                    child: Html(
                      data: context.read<SongData>().songs![index].lyrics,
                      style: {
                        'body': Style(
                          fontFamily: 'roboto',
                          fontSize: FontSize(18),
                          lineHeight: LineHeight(1.6),
                        ),
                        'b': Style(
                          fontWeight: FontWeight.w800,
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
