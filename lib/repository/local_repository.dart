import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';
import 'package:pageable_vaden/repository/base_repository.dart';
import 'package:pageable_vaden/sort.dart';

/// The class for LocalRepository implementation
///
/// This class only saves content locally, consuming RAM on the go.
///
/// Consider using either MySqlRepository, PostgreSqlRepository or MongoDbRepository.
class LocalRepository<T extends BaseModel, ID> extends BaseRepository<T, ID> {
  LocalRepository();

  @override
  Page<T> findAll({Pageable? pageable = const Pageable()}) {
    if (pageable == null) {
      return Page<T>(
        content: repository,
        size: 20,
        number: 0,
        totalElements: totalElements,
      );
    }

    List<T> sortedList = List.from(repository);

    for (var sort in pageable.sort.reversed) {
      sortedList.sort((a, b) {
        final aValue = getFieldValue(a, sort.sortBy);
        final bValue = getFieldValue(b, sort.sortBy);

        if (aValue is Comparable && bValue is Comparable) {
          return sort.type == SortType.ascending
              ? aValue.compareTo(bValue)
              : bValue.compareTo(aValue);
        }
        return 0;
      });
    }

    final pagedList = sortedList
        .skip(pageable.offset)
        .take(pageable.size)
        .toList();

    return Page<T>(
      content: pagedList,
      size: pageable.size,
      number: pageable.page,
      totalElements: totalElements,
    );
  }

  @override
  T? findById(ID id) {
    return repository.firstWhere((element) => element.id == id);
  }

  @override
  bool remove(ID id) {
    T model = repository.firstWhere((element) => element.id == id);
    return repository.remove(model);
  }

  @override
  T? save(T model, {SaveType? type = SaveType.insert}) {
    repository.add(model);
    return model;
  }

  @override
  Page<T> saveAll(
    List<T> list, {
    Pageable? pageable = const Pageable(),
    SaveType? type = SaveType.insert,
  }) {
    repository.addAll(list);
    return Page(
      content: repository,
      size: pageable!.size,
      number: pageable.page,
      totalElements: totalElements,
    );
  }
}
