import 'package:pageable_vaden/base_model.dart';

/// [Page] Class containing the page informations
class Page<T extends BaseModel> {
  /// The list of data to be managed/shown in page
  final List<T> content;

  /// The size of each page
  final int size;

  /// The current page number
  final int number;

  /// The total of elements contained in content's list
  late final int totalElements;

  /// The total existing pages
  late final int totalPages;

  /// Tells if it is the first page
  late final bool first;

  /// Tells if it is the last page
  late final bool last;

  Page({
    required this.content,
    this.size = 20,
    this.number = 0,
    this.totalElements = 0,
  }) {
    totalPages = (totalElements / size).floor() + 1;
    first = number == 0;
    last = number >= (totalPages - 1);
  }

  /// Converts the page to a Map
  ///
  /// Returns a [Map<String, dynamic>] containing the page information including the content
  Map<String, dynamic> toJson() => {
    "content": content.map((T e) => e.toJson()).toList(),
    "page": {
      "size": size,
      "page": number,
      "first": first,
      "last": last,
      "totalPages": totalPages,
      "totalElements": totalElements,
    },
  };
}
