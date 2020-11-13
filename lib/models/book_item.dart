import 'package:flutter/material.dart';

class BookItem {
  int pageId;
  String page;

  BookItem({@required this.pageId, @required this.page});

  Map<String, dynamic> toMap() {
    return {
      'pageId': pageId,
      'page': page,
    };
  }
}
