import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/screens/home_screen.dart';
import 'package:songbook_flutter/utilities/constants.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> _loading() async {
    await context.read<SongData>().loadDatabase();
    await context.read<BookData>().loadDatabase();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, HomeScreen.id);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loading());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.library_music,
                size: 72,
                color: Colors.white70,
              ),
              SizedBox(height: 24),
              Text(
                'CSI Songbook',
                style: kWelcomeHeaderTextStyle.copyWith(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                'Christian Service Institute',
                style: kSubtitleTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
