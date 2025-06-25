import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';
import 'package:pageable_vaden/repository/base_repository.dart';

/// The class for PostgreSqlRepository implementation
///
/// The content is saved on a server for the credentials given
abstract class PostgreSqlRepository<T extends BaseModel, ID>
    extends BaseRepository<T, ID> {
  /// Override this in every model to return the table name
  String get tableName;

  @override
  Page<T> findAll({Pageable? pageable}) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  T? findById(ID id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  bool remove(ID id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  T? save(T model, {SaveType? type = SaveType.insert}) {
    // TODO: implement save
    throw UnimplementedError();
  }

  @override
  Page<T> saveAll(
    List<T> list, {
    Pageable? pageable = const Pageable(),
    SaveType? type = SaveType.insert,
  }) {
    // TODO: implement saveAll
    throw UnimplementedError();
  }
}
