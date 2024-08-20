import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/models.dart';
import '../db.dart';

class FoodCategoryTable extends DatabaseManager {
  Future<List<FoodCategory>> getFoodCategories({int recipeId = 0}) async {
    final db = await database;

    // TODO: Afegir opció "Others"
    List<Map<String, Object?>>? results;

    if (recipeId == 0) {
      results = await db?.query("food_category", orderBy: "name ASC");
    } else {
      results = await db?.query("food_category", orderBy: "name ASC");
    }

    if (results == null) {
      results = [];
    }

    return results.map((e) => FoodCategory.fromJson(e)).toList();
  }

  Future<List<FoodCategory>> getFoodCategoriesByRecipeId(
    int recipeId,
  ) async {
    final recipe = Get.find<RecipeTable>(); // From DataManager
    final categories = await getFoodCategories();
    final recipes = await recipe.getRecipes();
    final currentRecipe = recipes.where((e) => e.id == recipeId).toList().first;

    for (int i = 0; i < categories.length; i++) {
      if (currentRecipe.foodCategoryId == categories[i].id) {
        categories[i].selected = true;
      } else {
        categories[i].selected = false;
      }
    }

    return categories;
  }

  Future<bool> newFoodCategory(FoodCategory foodCategory) async {
    final db = await database;

    final result = await db?.insert(
          "food_category",
          foodCategory.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ) ??
        0;

    print("newFoodCategory result: $result");
    return result > 0;
  }

  Future<bool> updateFoodCategory(FoodCategory foodCategory) async {
    final db = await database;

    final result = await db?.update(
          "food_category",
          foodCategory.toJson(),
          where: 'id = ?',
          whereArgs: [foodCategory.id],
        ) ??
        0;

    return result > 0;
  }

  Future<bool> deleteFoodCategory(int categoryId) async {
    final db = await database;

    final result = await db?.delete(
      "food_category",
      where: 'id = ?',
      whereArgs: [categoryId],
    );

    return result == 1;
  }
}
