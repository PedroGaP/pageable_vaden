import 'package:pageable_vaden/sort.dart';

class Pageable {
  final int page;
  final int size;
  final List<Sort> sort;

  int get offset => page * size;

  Pageable({this.page = 0, this.size = 20, this.sort = const []});
}
