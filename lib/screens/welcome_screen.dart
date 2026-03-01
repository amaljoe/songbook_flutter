import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/models/song_data.dart';
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: 72,
              color: cs.primary,
            ),
            SizedBox(height: 24),
            Text(
              'CSI Songbook',
              style: kWelcomeHeaderTextStyle.copyWith(color: cs.onSurface),
            ),
            SizedBox(height: 8),
            Text(
              'Church of South India',
              style: kSubtitleTextStyle.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
