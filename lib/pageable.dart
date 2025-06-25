import 'package:pageable_vaden/sort.dart';
import 'package:shelf/shelf.dart';

/// The pageable class to pass information to [Page]
class Pageable {
  /// The current page
  final int page;

  /// The size of each page
  final int size;

  /// The list of sorts the sort the contents list by
  final List<Sort> sort;

  /// The offset to be skipped for each page
  int get offset => page * size;

  const Pageable({this.page = 0, this.size = 20, this.sort = const []});

  /// Populates information by the given [request] data
  factory Pageable.fromRequest(Request request) {
    final queryParams = request.url.queryParametersAll;

    final size = int.tryParse(request.url.queryParameters['size'] ?? '');
    final page = int.tryParse(request.url.queryParameters['page'] ?? '');

    final sorts = queryParams['sort'] ?? [];

    final sortList = Sort.fromQuery(sorts);

    return Pageable(page: page ?? 0, size: size ?? 20, sort: sortList);
  }
}
