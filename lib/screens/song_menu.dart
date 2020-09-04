import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/song_toolbar.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/song_item.dart';
import 'package:songbook_flutter/song_item_manager.dart';

class SongMenu extends StatefulWidget {
  @override
  _SongMenuState createState() => _SongMenuState();
}

class _SongMenuState extends State<SongMenu> {
  SongItemManager songItemManager = SongItemManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Container(
            padding:
                EdgeInsets.only(top: kSongToolbarHeight - kToolbarBorderRadius),
            color: Colors.green,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                    top: kToolbarBorderRadius, left: 4, right: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SongItemWidget(
                      songItem: songItemManager.getSong(1),
                      onPressed: () {},
                    ),
                    SongItemWidget(
                      songItem: songItemManager.getSong(2),
                      onPressed: () {},
                    ),
                    SongItemWidget(
                      songItem: songItemManager.getSong(3),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          SongToolbar(),
        ]),
      ),
    );
  }
}

class SongItemWidget extends StatelessWidget {
  final SongItem songItem;
  final Function onPressed;

  SongItemWidget({
    @required this.songItem,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              songItem.num.toString(),
              style: kSongItemNumTextStyle,
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                songItem.title.toString(),
                style: kSongItemTitleTextStyle,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
