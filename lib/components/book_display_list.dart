import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class BookDisplayList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: context.watch<BookData>().pages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
                top: index == 0 ? kSongToolbarHeight / 2 + 8 : 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 6, spreadRadius: 0),
                ],
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Text(
                          '${index + 1}',
                          style: kPageNumberStyle,
                        ),
                      ),
                    ),
                    Html(data: context.watch<BookData>().pages[index].page),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
