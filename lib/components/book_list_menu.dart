import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/book_item_widget.dart';
import 'package:songbook_flutter/models/book_data.dart';

class BookListMenu extends StatefulWidget {
  final Function onPressed;

  BookListMenu({required this.onPressed});

  @override
  State<BookListMenu> createState() => _BookListMenuState();
}

class _BookListMenuState extends State<BookListMenu> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            context.select<BookData, int>((value) => value.pages?.length ?? 0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onPressed(index);
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
