import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_search.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:string_validator/string_validator.dart';

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
                          if (isNumeric(searchText) && searchText.length == 3) {
                            print('3 got');
                            context.read<SongData>().search(searchText);
                            context
                                .read<SongData>()
                                .openSong(searchText as int);
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                SongDisplay.id,
                                (Route<dynamic> route) =>
                                    route.isFirst ? true : false);
                          } else {
                            context.read<SongData>().search(searchText);
                          }
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
