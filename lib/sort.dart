enum SortType { ascending, descending }

/// Class Sort containing the information for sorting content
class Sort {
  /// The name of a field from a model
  final String sortBy;

  /// The type of sorting (Asc, Desc)
  final SortType type;

  Sort({required this.sortBy, required this.type});

  /// Generates a List of Sort from a query
  ///
  /// Returns a [List] of [Sort]
  ///
  /// [sortParams] The list of sorts given in the query param of a request
  static List<Sort> fromQuery(List<String> sortParams) {
    return sortParams.map((param) {
      final parts = param.split(',');
      final sortBy = parts[0];
      final direction = parts.length > 1 ? parts[1].toLowerCase() : 'asc';

      return Sort(
        sortBy: sortBy,
        type: direction == 'desc' ? SortType.descending : SortType.ascending,
      );
    }).toList();
  }

  @override
  String toString() {
    return "$sortBy ${type.name == "descending" ? "desc" : "asc"}";
  }
}
