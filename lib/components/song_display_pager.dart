import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/settings_data.dart';
import 'package:songbook_flutter/models/song_data.dart';

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
    final textSizeFactor = context.watch<SettingsData>().textSizeFactor;
    int songNum = context.read<SongData>().activeSong ?? 0;
    if (_controller.hasClients && _controller.page != songNum) {
      _controller.jumpToPage(songNum);
    }
    return PageView.builder(
        onPageChanged: (index) {
          context.read<SongData>().openSong(index);
        },
        controller: _controller,
        itemCount:
            context.select<SongData, int>((value) => value.songs?.length ?? 0),
        itemBuilder: (context, index) {
          return ListView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: [
              Html(
                data: context.read<SongData>().songs![index].lyrics,
                style: {
                  'body': Style(
                    fontFamily: 'roboto',
                    fontSize: FontSize(18 * textSizeFactor),
                    lineHeight: LineHeight(1.6),
                  ),
                  'b': Style(
                    fontWeight: FontWeight.w800,
                  ),
                  'h4': Style(
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  'h3': Style(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                    margin: Margins.symmetric(vertical: 8),
                  ),
                },
              ),
            ],
          );
        });
  }
}
