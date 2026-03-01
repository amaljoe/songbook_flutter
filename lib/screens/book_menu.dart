import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/book_list_menu.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/screens/book_display.dart';
import 'package:songbook_flutter/screens/settings_screen.dart';

class BookMenu extends StatelessWidget {
  static const String id = 'book_menu';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liturgy'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, SettingsScreen.id),
          ),
        ],
      ),
      body: BookListMenu(
        onPressed: (index) {
          context.read<BookData>().openPage(index);
          Navigator.pushNamed(context, BookDisplay.id);
        },
      ),
    );
  }
}
