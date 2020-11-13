import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/search_bar.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class Toolbar extends StatelessWidget {
  final navigationIcon;
  final ToolbarType type;
  final Function onIconPressed;
  final Widget childHeader;
  final Function onSearchPressed;

  Toolbar({
    @required this.navigationIcon,
    @required this.onIconPressed,
    @required this.type,
    @required this.childHeader,
    @required this.onSearchPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 0),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(kToolbarBorderRadius),
          bottomRight: Radius.circular(kToolbarBorderRadius),
        ),
      ),
      height: childHeader != null ? kSongToolbarHeight : kSongToolbarHeight / 2,
      child: Column(
        children: [
          Container(
            child: Row(
              children: [
                IconButton(
                  icon: navigationIcon,
                  iconSize: 30.0,
                  onPressed: onIconPressed,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: SearchBar(
                        text: type == ToolbarType.song
                            ? 'Search song title or number'
                            : 'Enter page number',
                        onPressed: onSearchPressed,
                        onTextChanged: (value) {},
                        autoFocus: false),
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
                Expanded(child: childHeader ?? Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ToolbarType { book, song }
