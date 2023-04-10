import 'package:flutter_myrecipesapp/db/db.dart';
import 'package:flutter_myrecipesapp/models/recipe_meal.dart';

class RecipeMealTable extends DatabaseManager {
  Future<List<RecipeMeal>> getRecipeMeals() async {
    final db = await database;
    final recipeMeals = await db?.query("recipe_meal") ?? [];

    return recipeMeals.map((e) => RecipeMeal.fromJson(e)).toList();
  }

  Future<bool> insertRecipeMeal(RecipeMeal recipeMeal) async {
    final db = await database;
    int? result;

    print("Mètode insertRecipeMeal");

    try {
      result = await db?.insert("recipe_meal", recipeMeal.toJson());
    } catch (e) {
      print("Excepció controlada: $e");
      return false;
    }

    print("result: $result");

    return result != null && result == 1;
  }
}
