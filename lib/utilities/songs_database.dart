import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song_item.dart';

//helper class dealing with songs database
class SongsDatabase {
  Database _database;

  //opens songs database
  Future<void> openSongsDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'songs_database.db');
    var exists = await databaseExists(path);

    if (!exists) {
      print("Creating new copy from asset");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data =
          await rootBundle.load(join("assets", "songs_database.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    _database = await openDatabase(path, readOnly: true);
  }

  //get all songs in the database
  Future<List<SongItem>> getAllSongs() async {
    print('getting all songs');
    final List<Map<String, dynamic>> maps = await _database.query('songs');
    return List.generate(maps.length, (index) {
      return SongItem(
        songId: maps[index]['songId'],
        title: maps[index]['title'],
        titleEng: maps[index]['titleEng'],
        lyrics: maps[index]['lyrics'],
      );
    });
  }

  //query through song titles
  Future<List<SongItem>> getSearchSongs(String searchText) async {
    if (searchText == null || searchText == '') {
      return [];
    }
    final List<Map<String, dynamic>> maps = await _database
        .query('songs', where: 'titleEng like ?', whereArgs: ['$searchText%']);
    return List.generate(maps.length, (index) {
      return SongItem(
        songId: maps[index]['songId'],
        title: maps[index]['title'],
        titleEng: maps[index]['titleEng'],
        lyrics: maps[index]['lyrics'],
      );
    });
  }

  //get song by number
  Future<List<SongItem>> getSearchSongsByNum(String searchText) async {
    if (searchText == null || searchText == '') {
      return [];
    }
    final List<Map<String, dynamic>> maps = await _database
        .query('songs', where: 'songId like ?', whereArgs: ['$searchText%']);
    return List.generate(maps.length, (index) {
      return SongItem(
        songId: maps[index]['songId'],
        title: maps[index]['title'],
        titleEng: maps[index]['titleEng'],
        lyrics: maps[index]['lyrics'],
      );
    });
  }
}
