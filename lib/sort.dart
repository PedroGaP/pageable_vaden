enum SortType { ascending, descending }

class Sort {
  final String sortBy;
  final SortType type;

  Sort({required this.sortBy, required this.type});

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
}
