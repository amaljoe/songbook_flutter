# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app on a connected device/emulator
flutter run

# Build for Android
flutter build apk

# Build for iOS
flutter build ios

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Get dependencies
flutter pub get

# Analyze code
flutter analyze
```

## Architecture

This is a Flutter app (Dart, targeting Android and iOS) for a Christian Malayalam songbook (CSI).

**State management**: Provider pattern with two `ChangeNotifier` classes:
- `SongData` (`lib/models/song_data.dart`) — manages the active song, full song list, and search results. Delegates DB operations to `SongsDatabase`.
- `BookData` (`lib/models/book_data.dart`) — manages the active page and book pages list. Delegates DB operations to `BooksDatabase`.

Both providers are registered at the root in `main.dart` via `MultiProvider`.

**Navigation**: Named routes with custom `PageRouteBuilder` transitions defined entirely in `main.dart`. Each screen has a static `id` constant used as its route name. `SongSearch` has two route ids (`id` and `idFromHome`) depending on where it's launched from.

**Data layer**: Two SQLite databases are bundled as assets (`assets/songs_database.db`, `assets/books_database.db`) and copied to the device's database directory on first launch (read-only). Helper classes `SongsDatabase` and `BooksDatabase` in `lib/utilities/` handle all DB access.

**Screen flow**:
1. `WelcomeScreen` — splash/loading screen; initializes Firebase, loads both databases, then navigates to `HomeScreen`
2. `HomeScreen` — tab container with `BottomNavigationBar` switching between `SongMenu` and `BookMenu`
3. `SongMenu` / `BookMenu` — list screens for browsing songs/book pages
4. `SongDisplay` — lyrics viewer with wakelock enabled (screen stays on); `PageView`-based pager in `SongDisplayPager` for swiping between songs
5. `BookDisplay` — book page viewer
6. `SongSearch` — search screen for songs by title (Manglish/transliterated) or song number

**UI conventions**:
- Shared text styles and layout constants are in `lib/utilities/constants.dart` (prefixed with `k`, e.g. `kSongLyricsTextStyle`, `kToolbarBorderRadius`)
- Custom fonts: `Pacifico` (headers), `roboto` (body/lyrics)
- Lyrics stored as HTML, rendered via `flutter_html`

**Key packages**: `sqflite`, `provider`, `firebase_core`, `flutter_html`, `google_fonts`, `wakelock`, `string_validator`
