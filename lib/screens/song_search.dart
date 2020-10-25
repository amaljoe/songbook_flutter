import 'package:flutter/material.dart';
import 'package:songbook_flutter/components/search_bar.dart';
import 'package:provider/provider.dart';
import 'package:songbook_flutter/components/song_list_search.dart';
import 'package:songbook_flutter/constants.dart';
import 'package:songbook_flutter/models/song_data.dart';
import 'package:songbook_flutter/screens/song_display.dart';
import 'package:songbook_flutter/screens/song_menu.dart';
import 'package:string_validator/string_validator.dart';

class SongSearch extends StatefulWidget {
  final bool fromHome;
  static const String idFromHome = 'song_search_home';
  static const String id = 'song_search';
  SongSearch({@required this.fromHome});
  @override
  _SongSearchState createState() => _SongSearchState();
}

class _SongSearchState extends State<SongSearch>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.fromHome ? 300 : 0));
    _controller.reverse(from: 1);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void gotoSong(int index) async {
    index -= kStarting;
    print('item $index pressed');
    context.read<SongData>().openSong(index);
    // Navigator.popUntil(context, (route) => route.isFirst);
    // Navigator.pushNamed(context, SongDisplay.id);
    if (widget.fromHome) {
      Navigator.pushReplacementNamed(context, SongDisplay.id);
    } else {
      Navigator.pop(context);
    }
  }

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
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.arrow_menu,
                      progress: _controller,
                    ),
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
                        onTextChanged: (String searchText) async {
                          if (isNumeric(searchText) && searchText.length == 3) {
                            print('3 are here');
                            int num = int.parse(searchText);
                            gotoSong(num);
                            print('3 are here for sure');
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
                child: SongListSearch(
                  onPressed: (index) {
                    gotoSong(
                        context.read<SongData>().searchSongs[index].songId);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
