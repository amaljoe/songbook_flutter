import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class BookDisplayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.only(
                top: kSongToolbarHeight / 2 - kToolbarBorderRadius),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.only(
                    top: kToolbarBorderRadius + 8, left: 16, right: 16),
                child: Text(
                  'context.read<SongData>().songs[index].lyrics',
                  style: kSongLyricsTextStyle,
                ),
              ),
            ),
          );
        });
  }
}
