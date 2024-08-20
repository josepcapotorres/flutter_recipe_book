import 'package:flutter_myrecipesapp/db/database_manager.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/models.dart';

class IngredientTable extends DatabaseManager {
  Future<List<Ingredient>> getIngredientsByRecipeId(int recipeId) async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.rawQuery('''
      SELECT ing.* 
      FROM recipe_ingredient ri 
      JOIN ingredient ing ON ri.idIngredient = ing.id 
      WHERE ri.idRecipe = $recipeId
      ''');

    if (results == null) {
      results = [];
    }

    return results.map((e) => Ingredient.fromJson(e)).toList();
  }

  Future<List<Ingredient>> getIngredientsByName(
      int? recipeId, String ingName) async {
    final db = await database;

    String queryWithRecipeId = """
      SELECT ing.* 
      FROM recipe_ingredient ri 
      JOIN ingredient ing ON ri.idIngredient = ing.id 
      WHERE ing.name LIKE '%$ingName%' AND ri.idRecipe = $recipeId
    """;

    String queryWithoutRecipeId = """
      SELECT ing.* 
      FROM ingredient ing 
      WHERE ing.name LIKE '%$ingName%'    
    """;

    List<Map<String, Object?>>? results = await db?.rawQuery(
      recipeId == null ? queryWithoutRecipeId : queryWithRecipeId,
    );

    if (results == null) {
      results = [];
    }

    return results.map((e) => Ingredient.fromJson(e)).toList();
  }

  Future<void> addIngredientToRecipe(int recipeId) async {}

  Future<List<Ingredient>> getIngredients() async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.rawQuery('''
      SELECT *
      FROM ingredient 
      ORDER BY name ASC
      ''');

    if (results == null) {
      results = [];
    }

    return results.map((e) => Ingredient.fromJson(e)).toList();
  }

  Future<bool> deleteIngredient(int ingredientId) async {
    final db = await database;

    final result = await db?.delete(
      "ingredient",
      where: 'id = ?',
      whereArgs: [ingredientId],
    );

    return result == 1;
  }

  Future<bool> updateIngredient(Ingredient ingredient) async {
    final db = await database;

    final resultsUpdated = await db?.update(
      "ingredient",
      ingredient.toJson(),
      where: "id = ?",
      whereArgs: [ingredient.id!],
    );

    return resultsUpdated != null && resultsUpdated > 0;
  }

  Future<bool> newIngredient(Ingredient ingredient) async {
    final db = await database;

    final result = await db?.insert(
          "ingredient",
          ingredient.toJson(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ) ??
        0;

    return result > 0;
  }
}
