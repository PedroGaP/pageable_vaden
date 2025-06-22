abstract class BaseModel<ID> {
  final ID id;

  BaseModel({required this.id});

  Map toJson() {
    throw UnimplementedError("Model toJson was not implemented!");
  }
}
