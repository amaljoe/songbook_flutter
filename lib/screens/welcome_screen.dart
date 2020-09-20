import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/screens/song_menu.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome_screen';

  Future<void> loading(BuildContext context) async {
    print('entered main loading');
    await Firebase.initializeApp();
    await context.read<SongData>().loadDatabase();
    print('exiting main loading');
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: loading(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('failure');
            return Container(
              child: Center(child: Text('error')),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            print('success');
            return Container(
              color: Colors.white,
              child: Center(
                child: Text('success'),
              ),
            );
          } else {
            print('loading');
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
