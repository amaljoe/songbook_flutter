import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class BookDisplayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pages = context.watch<BookData>().pages;
    final activePage = context.watch<BookData>().activePage;

    if (pages == null || activePage == null) {
      return Center(child: CircularProgressIndicator());
    }

    final item = pages[activePage];

    return SingleChildScrollView(
      padding: EdgeInsets.only(
          top: kSongToolbarHeight / 2 + 8, left: 16, right: 16, bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 6, spreadRadius: 0),
          ],
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  item.title,
                  style: kLiturgyTitleTextStyle,
                ),
              ),
              Html(
                data: item.page,
                style: {
                  'body': Style(
                    fontFamily: 'roboto',
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.6),
                  ),
                  'em': Style(
                    color: Colors.blueGrey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
