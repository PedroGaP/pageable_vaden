import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';
import 'package:pageable_vaden/repository/base_repository.dart';

class MySqlRepository<T, ID> extends BaseRepository {
  @override
  Page<BaseModel> findAll({Pageable? pageable}) {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  @override
  BaseModel? findById(int id) {
    // TODO: implement findById
    throw UnimplementedError();
  }

  @override
  bool remove(int id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  BaseModel? save(BaseModel model) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
