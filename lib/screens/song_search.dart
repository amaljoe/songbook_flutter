import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/components/song_list_search.dart';
import 'package:songbook_flutter/models/search_history.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/song_display.dart';

class SongSearch extends StatefulWidget {
  final bool fromHome;
  static const String idFromHome = 'song_search_home';
  static const String id = 'song_search';

  SongSearch({required this.fromHome});

  @override
  State<SongSearch> createState() => _SongSearchState();
}

class _SongSearchState extends State<SongSearch> {
  bool _numpadMode = true;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _gotoSong(int songId) {
    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      context.read<SearchHistoryData>().addSearch(query);
    }
    context.read<SearchHistoryData>().recordOpen(songId);
    context.read<SongData>().openSong(songId - 1);
    if (widget.fromHome) {
      Navigator.pushReplacementNamed(context, SongDisplay.id);
    } else {
      Navigator.pop(context);
    }
  }

  void _toggleMode() {
    _focusNode.unfocus();
    setState(() => _numpadMode = !_numpadMode);
    _controller.clear();
    context.read<SongData>().clearSearch();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  void _applyChip(String query) {
    _controller.text = query;
    _controller.selection =
        TextSelection.fromPosition(TextPosition(offset: query.length));
    context.read<SongData>().search(query);
  }

  Widget _buildEmptyState(BuildContext context) {
    final history = context.watch<SearchHistoryData>();
    final songs = context.read<SongData>().songs ?? [];
    final frequent = history.topSongs(songs);
    final hasRecent = history.recentSearches.isNotEmpty;
    final hasFrequent = frequent.isNotEmpty;

    if (!hasRecent && !hasFrequent) {
      return Center(
        child: Text(
          'Type a song number or title to search',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView(
      children: [
        if (hasRecent) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Recent',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: history.recentSearches
                  .map((q) => ActionChip(
                        avatar: Icon(Icons.history, size: 16),
                        label: Text(q),
                        onPressed: () => _applyChip(q),
                      ))
                  .toList(),
            ),
          ),
        ],
        if (hasFrequent) ...[
          if (hasRecent) Divider(height: 24),
          Padding(
            padding: EdgeInsets.fromLTRB(16, hasRecent ? 0 : 16, 16, 8),
            child: Text(
              'Frequently Opened',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ...frequent.map(
            (song) => GestureDetector(
              onTap: () => _gotoSong(song.songId),
              child: SongItemWidget(songItem: song),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _controller.text.isEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          keyboardType:
              _numpadMode ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: _numpadMode ? 'Song number' : 'Search by title',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            if (_numpadMode &&
                int.tryParse(text) != null &&
                text.length == 3) {
              _gotoSong(int.parse(text));
            } else {
              context.read<SongData>().search(text);
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_numpadMode ? Icons.abc : Icons.dialpad),
            tooltip:
                _numpadMode ? 'Switch to title search' : 'Switch to number',
            onPressed: _toggleMode,
          ),
        ],
      ),
      body: isEmpty
          ? _buildEmptyState(context)
          : SongListSearch(
              onPressed: (index) {
                _gotoSong(context.read<SongData>().searchSongs[index].songId);
              },
            ),
    );
  }
}
