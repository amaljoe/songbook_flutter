import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome_screen';

  Future<void> loading(BuildContext context) async {
    print('entered');
    FirebaseApp _initialise = await Firebase.initializeApp();
    await context
        .select<SongData, Future<void>>((value) => value.loadDatabase());
    print('entered2');
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: loading(context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Center(child: Text('error')),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Text('success'),
              ),
            );
          } else {
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
