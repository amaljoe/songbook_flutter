import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:songbook_flutter/models/book_item.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song_item.dart';

//helper class dealing with songs database
class BooksDatabase {
  Database _database;

  //opens songs database
  Future<void> openBooksDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'books_database.db');
    var exists = await databaseExists(path);

    if (!exists) {
      print("Creating new copy from asset");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data =
          await rootBundle.load(join("assets", "books_database.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    _database = await openDatabase(path, readOnly: true);
  }

  //get all songs in the database
  Future<List<BookItem>> getAllPages() async {
    print('getting all pages');
    final List<Map<String, dynamic>> maps = await _database.query('books');
    return List.generate(maps.length, (index) {
      return BookItem(
        pageId: maps[index]['pageId'],
        page: maps[index]['page'],
      );
    });
  }
}
