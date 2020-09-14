import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:songbook_flutter/screens/song_menu.dart';
import '../constants.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/song_data.dart';

class LoadingScreen extends StatefulWidget {
  final context;
  static const String id = 'loading_screen';

  LoadingScreen({this.context});
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    loadSongsDatabase();
  }

  void loadSongsDatabase() async {
    await Provider.of<SongData>(widget.context).loadDatabase();
    Navigator.pushNamed(widget.context, SongMenu.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Hero(
            tag: 'appTitle',
            child: Text(
              'Songbook',
              style: GoogleFonts.pacifico(
                fontSize: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
