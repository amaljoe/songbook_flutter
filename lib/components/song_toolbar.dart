import 'package:flutter/material.dart';
import 'package:songbook_flutter/constants.dart';

class SongToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: kToolbarTopPadding),
      height: kSongToolbarHeight,
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.menu),
                  iconSize: 30.0,
                  onPressed: () {},
                )
              ],
            ),
            color: Colors.purple,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(kToolbarBorderRadius),
                        bottomRight: Radius.circular(kToolbarBorderRadius),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
