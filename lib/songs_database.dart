import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/song_item.dart';

void main() async {
  SongsDatabase songsDatabase = SongsDatabase();
  await songsDatabase.openSongsDatabase();
  List<SongItem> songs = await songsDatabase.getAllSongs();
  print(songs[0].title);
}

class SongsDatabase {
  Database _database;

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

  Future<List<SongItem>> getSearchSongs(String searchText) async {
    final List<Map<String, dynamic>> maps = await _database
        .query('songs', where: 'titleEng like ?', whereArgs: ['%$searchText%']);
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
