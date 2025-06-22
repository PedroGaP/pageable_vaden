import 'package:pageable_vaden/base_model.dart';

class Page<T extends BaseModel> {
  final List<T> content;
  final int size;
  final int number;

  late final int totalElements;
  late final int totalPages;
  late final bool first;
  late final bool last;

  Page({
    required this.content,
    required this.size,
    required this.number,
    required this.totalElements,
  }) {
    totalPages = (totalElements / size).floor() + 1;
    first = number == 0;
    last = number >= (totalPages - 1);
  }

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
