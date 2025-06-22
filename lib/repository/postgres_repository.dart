import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';
import 'package:pageable_vaden/repository/base_repository.dart';

class PostgresRepository<T extends BaseModel, ID>
    extends BaseRepository<T, ID> {
  @override
  Page<T> findAll({Pageable? pageable}) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  T? findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  bool remove(int id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  T? save(T model) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
