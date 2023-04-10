import 'package:flutter_myrecipesapp/db/db.dart';
import 'package:flutter_myrecipesapp/models/models.dart';

class MealTable extends DatabaseManager {
  Future<List<Meal>> getMeals() async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.query(
      "meal",
      orderBy: "order_index ASC",
    );

    if (results == null) {
      results = [];
    }

    return results.map((e) => Meal.fromJson(e)).toList();
  }

  Future<Meal?> getMealById(int mealId) async {
    final db = await database;

    List<Map<String, Object?>>? results =
        await db?.query("meal", where: "id = ?", whereArgs: [mealId]);

    if (results != null && results.isNotEmpty) {
      return Meal.fromJson(results.first);
    } else {
      return null;
    }
  }

  Future<List<Meal>> getMealsByRecipeId(int recipeId) async {
    final db = await database;

    // Mostrar tots meals, però amb el camp "selected" que
    // estigui relacionat amb la recepta guardada

    List<Map<String, Object?>>? meals = await db?.query("meal");
    List<Map<String, Object?>>? selectedMeals = await db?.rawQuery("""
      SELECT m.*
      FROM recipe_meal rm
      JOIN meal m ON rm.mealId = m.id
      WHERE rm.recipeId = ?
    """, [recipeId]);

    List<Meal> returnedMeals = [];

    for (final currentMeal in meals!) {
      final selectedFound = selectedMeals
              ?.where((e) => e["id"] == currentMeal["id"])
              .toList()
              .length ==
          1;

      final meal = Meal.fromJson(currentMeal);
      meal.selected = selectedFound;

      returnedMeals.add(meal);
    }

    return returnedMeals;
  }

  Future<bool> newMeal(Meal meal) async {
    final db = await database;

    final result = await db?.insert("meal", meal.toJson()) ?? 0;

    return result > 0;
  }

  Future<bool> updateMeal(Meal meal) async {
    final db = await database;

    final result = await db?.update(
          "meal",
          meal.toJson(),
          where: 'id = ?',
          whereArgs: [meal.id],
        ) ??
        0;

    return result > 0;
  }

  Future<bool> deleteMeal(int mealId) async {
    final db = await database;

    final result = await db?.delete(
      "meal",
      where: 'id = ?',
      whereArgs: [mealId],
    );

    return result == 1;
  }

  Future<void> changeMealOrder(Meal oldMeal, Meal newMeal) async {
    final db = await database;

    final tempOrderIndex = oldMeal.orderIndex;
    oldMeal.orderIndex = newMeal.orderIndex;
    newMeal.orderIndex = tempOrderIndex;

    await db?.update(
      "meal",
      newMeal.toJson(),
      where: "id = ?",
      whereArgs: [newMeal.id!],
    );

    await db?.update(
      "meal",
      oldMeal.toJson(),
      where: "id = ?",
      whereArgs: [oldMeal.id!],
    );
  }
}
