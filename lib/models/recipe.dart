import 'dart:convert';

import 'meals.dart';

class Recipe {
  int? id;
  String? name;
  late int nPersons;
  late String stepsReproduce;
  late int foodCategoryId;
  List<Meal> meals = [];

  Recipe({
    required this.id,
    required this.name,
    required this.nPersons,
    required this.stepsReproduce,
    required this.foodCategoryId,
    required this.meals,
  });

  Recipe.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        nPersons = int.tryParse(json['n_persons'].toString()) ?? 0,
        stepsReproduce = json['steps_reproduce'],
        foodCategoryId = json['food_category_id'],
        meals = json.containsKey("meals")
            ? (json["meals"] as List<Map<String, dynamic>>)
                .map((e) => Meal.fromJson(e))
                .toList()
            : [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'n_persons': nPersons,
        'steps_reproduce': stepsReproduce,
        'food_category_id': foodCategoryId,
      };

  @override
  bool operator ==(Object other) {
    if (other is Recipe) {
      return id == other.id &&
          name == other.name &&
          nPersons == other.nPersons &&
          stepsReproduce == other.stepsReproduce &&
          foodCategoryId == other.foodCategoryId;
    } else {
      return false;
    }
  }

  @override
  toString() {
    return jsonEncode(toJson());
  }
}
