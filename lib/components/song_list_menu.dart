import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_item_widget.dart';
import 'package:songbook_flutter/models/song_data.dart';

class SongListMenu extends StatelessWidget {
  final Function onPressed;

  SongListMenu({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView.builder(
      itemCount: context.select<SongData, int>((value) => value.songs?.length ?? 0),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onPressed(index);
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
