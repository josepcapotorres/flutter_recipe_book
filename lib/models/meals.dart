class Meal {
  int? id;
  int? recipeId;
  int? orderIndex;
  late String name;
  bool selected = false;

  Meal();

  Meal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        orderIndex = json["order_index"],
        recipeId = json['recipe_id'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        "order_index": orderIndex,
      };

  @override
  bool operator ==(Object other) {
    if (other is Meal) {
      return id == other.id && name == other.name;
    } else {
      return false;
    }
  }
}
