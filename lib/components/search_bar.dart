import 'package:flutter/material.dart';

import '../constants.dart';

class SearchBar extends StatelessWidget {
  final Function onPressed;
  final Function onTextChanged;
  final bool autoFocus;

  SearchBar({
    @required this.onPressed,
    @required this.onTextChanged,
    @required this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1.5),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: GestureDetector(
        onTap: onPressed,
        child: TextField(
          onChanged: onTextChanged,
          autofocus: autoFocus,
          enabled: autoFocus,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            icon: Padding(
              padding: EdgeInsets.only(left: 12.0),
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
    );
  }
}
