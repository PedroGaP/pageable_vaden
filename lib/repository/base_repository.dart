import 'dart:async';

import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';

enum SaveType { update, insert }

/// The base repository interface to be implemented by other repositories
abstract class BaseRepository<T extends BaseModel, ID> {
  /// The list of data in the repository
  final List<T> _repository = [];

  /// The list of data in the repository
  List<T> get repository => _repository;

  /// The total of elements contained in the repository list
  int get totalElements => _repository.length;

  /// Retrieve all data from the repository list
  ///
  /// Returns a [Page<T>] for the data found
  ///
  /// [pageable] The information for the page
  FutureOr<Page<T>> findAll({Pageable? pageable});

  /// Retrieve a data by its id
  ///
  /// Returns a [T?] for the data found
  ///
  /// [id] The given data id
  FutureOr<T?> findById(ID id);

  /// Save a data into the repository data list
  ///
  /// Returns a [T?] containing the saved data information
  ///
  /// [model] The given data to be saved
  /// [type] The given save type
  FutureOr<T?> save(T model, {SaveType type});

  /// Save a list of data into the repository data list
  ///
  /// Returns a [Page] containing the data list information
  ///
  /// [list] The given data list to be saved
  /// [pageable] The given page information
  /// [type] The geiven save type
  FutureOr<Page<T>> saveAll(
    List<T> list, {
    Pageable? pageable = const Pageable(),
    SaveType? type = SaveType.insert,
  });

  /// Removes a data from the repository data lisst
  ///
  /// Returns [bool] if data is removed successfuly
  ///
  /// [id] The given data id to be removed
  FutureOr<bool> remove(ID id);

  dynamic getFieldValue(BaseModel object, String fieldName) {
    if (fieldName == 'id') return object.id;
    return object.toJson()[fieldName];
  }
}
