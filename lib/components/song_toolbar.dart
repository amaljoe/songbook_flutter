import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/search_bar.dart';
import 'package:songbook_flutter/constants.dart';

class SongToolbar extends StatelessWidget {
  final IconData navigationIcon;
  final Function onIconPressed;
  final Widget childHeader;
  final Function onSearchPressed;

  SongToolbar({
    @required this.navigationIcon,
    @required this.onIconPressed,
    @required this.childHeader,
    @required this.onSearchPressed,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 2)),
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
                  icon: Icon(navigationIcon),
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
                Expanded(child: childHeader),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
