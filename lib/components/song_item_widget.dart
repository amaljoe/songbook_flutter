import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/song_item.dart';
import '../constants.dart';

class SongItemWidget extends StatelessWidget {
  final SongItem songItem;

  SongItemWidget({
    @required this.songItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 12.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            songItem.songId.toString(),
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
    );
  }
}
