import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_menu.dart';
import 'package:songbook_flutter/components/song_list_search.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/models/song_item.dart';

class SongSearch extends StatelessWidget {
  static const String id = 'song_search';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    iconSize: 30.0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: SearchBar(
                        onPressed: () {},
                        onTextChanged: (String searchText) {
                          print(searchText);
                          context.read<SongData>().search(searchText);
                        },
                        autoFocus: true,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: SongListSearch(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
