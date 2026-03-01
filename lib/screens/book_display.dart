import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/book_display_list.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class BookDisplay extends StatefulWidget {
  static const String id = 'book_display';

  @override
  _BookDisplayState createState() => _BookDisplayState();
}

class _BookDisplayState extends State<BookDisplay> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = context.watch<BookData>().pages;
    final activePage = context.watch<BookData>().activePage;
    final title =
        (pages != null && activePage != null) ? pages[activePage].title : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: BookDisplayList(),
    );
  }
}
