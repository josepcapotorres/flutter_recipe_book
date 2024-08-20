import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  int? id;
  String? name;

  Ingredient();

  Ingredient.fromJson(Map<String, dynamic> map) {
    id = map.containsKey("id") ? map["id"] : null;
    name = map.containsKey("name") ? map["name"] : null;
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }

  @override
  List<Object?> get props => [id, name];

  @override
  bool? get stringify => true;
}
