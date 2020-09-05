import 'package:flutter/material.dart';
import 'package:songbook_flutter/song_item.dart';
import '../constants.dart';

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
      ),
    );
  }
}
