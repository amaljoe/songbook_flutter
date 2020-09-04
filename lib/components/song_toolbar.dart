import 'package:flutter/material.dart';
import 'package:songbook_flutter/constants.dart';

class SongToolbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(kToolbarBorderRadius),
          bottomRight: Radius.circular(kToolbarBorderRadius),
        ),
      ),
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
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          icon: Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                          hintText: 'Search song title or number',
                          border: InputBorder.none,
                          hintStyle: kSearchTextStyle,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
