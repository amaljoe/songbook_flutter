class BookItem {
  final int pageId;
  final String title;
  final String page;

  BookItem({required this.pageId, required this.title, required this.page});

  Map<String, dynamic> toMap() {
    return {
      'pageId': pageId,
      'title': title,
      'page': page,
    };
  }
}
