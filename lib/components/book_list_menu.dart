import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/book_item_widget.dart';
import 'package:songbook_flutter/models/book_data.dart';

class BookListMenu extends StatelessWidget {
  final Function onPressed;

  BookListMenu({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
      itemCount: context.select<BookData, int>((value) => value.pages?.length ?? 0),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onPressed(index);
          },
          child: BookItemWidget(
            bookItem: context.read<BookData>().pages![index],
          ),
        );
      },
      ),
    );
  }
}
