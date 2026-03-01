import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:songbook_flutter/models/book_item.dart';
import 'package:sqflite/sqflite.dart';

class BooksDatabase {
  Database? _database;

  Future<void> openBooksDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'books_database.db');
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Always overwrite from assets — the DB is read-only app content.
    ByteData data =
        await rootBundle.load(join("assets", "books_database.db"));
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);

    _database = await openDatabase(path);
  }

  Future<List<BookItem>> getAllPages() async {
    final List<Map<String, dynamic>> maps = await _database!
        .query('books', columns: ['pageId', 'title', 'page'], orderBy: 'pageId');
    return List.generate(maps.length, (index) {
      return BookItem(
        pageId: maps[index]['pageId'],
        title: maps[index]['title'],
        page: maps[index]['page'],
      );
    });
  }
}
