/// The Base Model interface for every model created
abstract class BaseModel<ID> {
  /// The id of the data
  final ID id;

  BaseModel({required this.id});

  /// Parses the data to a map
  ///
  /// Returns a [Map] for the parsed information
  Map toJson() {
    throw UnimplementedError("Model toJson was not implemented!");
  }
}
