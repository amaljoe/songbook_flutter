import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/main.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/models/settings_data.dart';
import 'package:songbook_flutter/models/song_data.dart';

void main() {
  testWidgets('App smoke test — welcome screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsData>(create: (_) => SettingsData()),
          ChangeNotifierProvider<SongData>(create: (_) => SongData()),
          ChangeNotifierProvider<BookData>(create: (_) => BookData()),
        ],
        child: MyApp(),
      ),
    );

    // Welcome screen should show the app title.
    expect(find.text('CSI Songbook'), findsOneWidget);
  });
}
