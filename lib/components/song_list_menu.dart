import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/models/song_data.dart';

class SongListMenu extends StatefulWidget {
  final Function onPressed;

  SongListMenu({required this.onPressed});

  @override
  State<SongListMenu> createState() => _SongListMenuState();
}

class _SongListMenuState extends State<SongListMenu> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: ListView.builder(
        controller: _scrollController,
        itemCount:
            context.select<SongData, int>((value) => value.songs?.length ?? 0),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onPressed(index);
            },
            child: SongItemWidget(
              songItem: context.read<SongData>().songs![index],
            ),
          );
        },
      ),
    );
  }
}
