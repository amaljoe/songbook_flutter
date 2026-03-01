import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/models/book_data.dart';
import 'package:songbook_flutter/models/settings_data.dart';
import 'package:songbook_flutter/screens/book_display.dart';
import 'package:songbook_flutter/screens/settings_screen.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_search.dart';
import 'package:songbook_flutter/screens/welcome_screen.dart';
import 'models/song_data.dart';
import 'screens/home_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final settings = SettingsData();
  await settings.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsData>.value(value: settings),
        ChangeNotifierProvider<SongData>(create: (_) => SongData()),
        ChangeNotifierProvider<BookData>(create: (_) => BookData()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsData>(
      builder: (context, settings, _) {
        return MaterialApp(
          initialRoute: WelcomeScreen.id,
          themeMode: settings.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF1565C0)),
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF1565C0),
              brightness: Brightness.dark,
            ),
            fontFamily: GoogleFonts.roboto().fontFamily,
          ),
          onGenerateRoute: (routeSettings) {
            switch (routeSettings.name) {
              case HomeScreen.id:
                return MaterialPageRoute(builder: (_) => HomeScreen());
              case SongDisplay.id:
                return MaterialPageRoute(builder: (_) => SongDisplay());
              case BookDisplay.id:
                return MaterialPageRoute(builder: (_) => BookDisplay());
              case WelcomeScreen.id:
                return MaterialPageRoute(builder: (_) => WelcomeScreen());
              case SongSearch.idFromHome:
                return MaterialPageRoute(
                    builder: (_) => SongSearch(fromHome: true));
              case SongSearch.id:
                return MaterialPageRoute(
                    builder: (_) => SongSearch(fromHome: false));
              case SettingsScreen.id:
                return MaterialPageRoute(builder: (_) => SettingsScreen());
              default:
                return MaterialPageRoute(builder: (_) => WelcomeScreen());
            }
          },
        );
      },
    );
  }
}
