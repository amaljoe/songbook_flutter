import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_search.dart';
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
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _gotoSong(int songId) {
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

  @override
  Widget build(BuildContext context) {
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
            tooltip: _numpadMode ? 'Switch to title search' : 'Switch to number',
            onPressed: _toggleMode,
          ),
        ],
      ),
      body: SongListSearch(
        onPressed: (index) {
          _gotoSong(context.read<SongData>().searchSongs[index].songId);
        },
      ),
    );
  }
}
