import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/book_item_widget.dart';
import 'package:songbook_flutter/models/book_data.dart';
import '../utilities/constants.dart';

class BookListMenu extends StatelessWidget {
  final Function onPressed;

  BookListMenu({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double topPadding;
    return ListView.builder(
      itemCount: context.select<BookData, int>((value) => value.pages?.length ?? 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          topPadding = kToolbarBorderRadius;
        } else {
          topPadding = 0;
        }
        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: GestureDetector(
            onTap: () {
              onPressed(index);
            },
            child: BookItemWidget(
              bookItem: context.read<BookData>().pages![index],
            ),
          ),
        );
      },
    );
  }
}
