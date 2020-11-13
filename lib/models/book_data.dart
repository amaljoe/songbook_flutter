import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/book_item.dart';
import 'package:songbook_flutter/utilities/books_database.dart';

class BookData extends ChangeNotifier {
  int activePage;
  List<BookItem> pages;
  BooksDatabase booksDatabase;

  BookData() {
    booksDatabase = BooksDatabase();
  }

  void openPage(int num) {
    activePage = num;
    notifyListeners();
  }

  Future<void> loadDatabase() async {
    await booksDatabase.openBooksDatabase();
    pages = await booksDatabase.getAllPages();
    print('books loaded');
    notifyListeners();
  }
}
