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
    print('entered main loading');
    await context.read<SongData>().loadDatabase();
    await context.read<BookData>().loadDatabase();
    print('exiting main loading');
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
        child: Center(
          child: Text(
            'Songbook',
            style: kWelcomeHeaderTextStyle,
          ),
        ),
      ),
    );
  }
}
