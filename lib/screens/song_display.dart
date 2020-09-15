import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/models/song_data.dart';
import '../components/song_item_widget.dart';

class SongDisplay extends StatefulWidget {
  static const String id = 'song_display';

  @override
  _SongDisplayState createState() => _SongDisplayState();
}

class _SongDisplayState extends State<SongDisplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(children: [
          PageView.builder(
              onPageChanged: (index) {
                print('actually $index');
                Provider.of<SongData>(context, listen: false).openSong(index);
              },
              controller: PageController(
                  initialPage:
                      Provider.of<SongData>(context, listen: false).activeSong),
              itemCount:
                  Provider.of<SongData>(context, listen: false).songs.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: EdgeInsets.only(
                      top: kSongToolbarHeight - kToolbarBorderRadius),
                  child: ListView(children: [
                    Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: kToolbarBorderRadius + 8, left: 16, right: 16),
                        child: Text(
                          Provider.of<SongData>(context, listen: false)
                              .songs[index]
                              .lyrics,
                          style: kSongLyricsTextStyle,
                        ),
                      ),
                    ),
                  ]),
                );
              }),
          SongToolbar(
            navigationIcon: Icons.arrow_back,
            onIconPressed: () {
              Navigator.pop(context);
            },
            childHeader: Padding(
              padding: EdgeInsets.only(left: 20, top: 10),
              child: Center(
                child: SongItemWidget(
                    songItem: Provider.of<SongData>(context, listen: false)
                        .songs[Provider.of<SongData>(context).activeSong]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
