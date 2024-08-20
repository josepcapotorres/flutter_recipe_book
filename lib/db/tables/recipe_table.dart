import 'package:flutter_myrecipesapp/db/database_manager.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/models.dart';

class RecipeTable extends DatabaseManager {
  Future<List<Recipe>> getRecipes() async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.query("recipe");

    if (results == null) {
      results = [];
    }

    return results.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<Recipe?> getRecipeById(int recipeId) async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.query(
      "recipe",
      where: "id = ?",
      whereArgs: [recipeId],
    );

    if (results == null) {
      return null;
    }

    if (results.isEmpty) {
      return null;
    }

    return Recipe.fromJson(results.first);
  }

  Future<int> newRecipe(Recipe recipe) async {
    final db = await database;

    final result = await db?.insert(
          "recipe",
          recipe.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ) ??
        0;

    return result;
  }

  Future<bool> updateRecipe(Recipe recipe) async {
    final db = await database;

    final result = await db?.update(
          "recipe",
          recipe.toJson(),
          where: 'id = ?',
          whereArgs: [recipe.id],
        ) ??
        0;

    return result > 0;
  }

  Future<bool> deleteRecipe(int recipeId) async {
    final db = await database;

    final result = await db?.delete(
      "recipe",
      where: 'id = ?',
      whereArgs: [recipeId],
    );

    return result == 1;
  }
}
