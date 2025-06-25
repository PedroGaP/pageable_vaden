import 'package:pageable_vaden/pageable_vaden.dart';
import 'package:shelf/shelf.dart';

/// The Request extension to access Pageable information on request
extension PageableRequestExtension on Request {
  Pageable get pageable {
    final queryParams = url.queryParametersAll;

    final size = int.tryParse(url.queryParameters['size'] ?? '');
    final page = int.tryParse(url.queryParameters['page'] ?? '');

    final sorts = queryParams['sort'] ?? [];

    final sortList = Sort.fromQuery(sorts);

    return Pageable(page: page ?? 0, size: size ?? 20, sort: sortList);
  }
}
