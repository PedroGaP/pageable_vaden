import 'package:pageable_vaden/base_model.dart';
import 'package:pageable_vaden/page.dart';
import 'package:pageable_vaden/pageable.dart';

abstract class BaseRepository<T extends BaseModel, ID> {
  final List<T> _repository = [];
  List<T> get repository => _repository;
  int get totalElements => _repository.length;

  Page<T> findAll({Pageable? pageable});

  T? findById(int id);

  T? save(T model);

  bool remove(int id);

  dynamic getFieldValue(BaseModel object, String fieldName) {
    if (fieldName == 'id') return object.id;
    return object.toJson()[fieldName];
  }
}
