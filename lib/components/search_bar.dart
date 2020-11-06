import 'package:flutter/material.dart';

import '../utilities/constants.dart';

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
    return GestureDetector(
      onTap: onPressed,
      child: TextField(
        onChanged: onTextChanged,
        autofocus: autoFocus,
        enabled: autoFocus,
        keyboardType: TextInputType.visiblePassword,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          hintText: 'Search song title or number',
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 1),
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          contentPadding: EdgeInsets.all(8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          hintStyle: kSearchTextStyle,
        ),
      ),
    );
  }
}
