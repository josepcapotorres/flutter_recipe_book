class FoodCategory {
  int? id;
  late String name;
  bool selected = false;

  FoodCategory();

  FoodCategory.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  bool operator ==(Object other) {
    if (other is FoodCategory) {
      return id == other.id && name == other.name;
    } else {
      return false;
    }
  }
}
