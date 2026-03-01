import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/book_item.dart';
import '../utilities/constants.dart';

class BookItemWidget extends StatelessWidget {
  final BookItem bookItem;

  BookItemWidget({required this.bookItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            bookItem.pageId.toString(),
            style: kSongItemNumTextStyle,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              bookItem.title,
              style: kSongItemTitleTextStyle,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
