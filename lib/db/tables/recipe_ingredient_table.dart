import 'package:flutter_myrecipesapp/db/database_manager.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/models.dart';

class RecipeIngredientTable extends DatabaseManager {
  Future<List<RecipeIngredient>> getRecipeIngredients() async {
    final db = await database;

    final result = await db?.query("recipe_ingredient");

    return result?.map((e) => RecipeIngredient.fromJson(e)).toList() ?? [];
  }

  Future<List<RecipeIngredient>> getIngredientsByRecipeId(int recipeId) async {
    final db = await database;

    final result = await db?.rawQuery("""
      SELECT ri.id, ri.idIngredient, ri.unit, ri.quantityIngredient, ri.idRecipe, ing.name AS 'ingredient_name'
      FROM recipe_ingredient ri 
      JOIN ingredient ing ON ri.idIngredient = ing.id 
      WHERE ri.idRecipe = $recipeId
    """);

    return result?.map((e) => RecipeIngredient.fromJson(e)).toList() ?? [];
  }

  Future<bool> newRecipeIngredient(
      List<RecipeIngredient> recipeIngredient) async {
    final db = await database;

    Batch batch = db!.batch();

    recipeIngredient.forEach((e) {
      batch.insert(
        'recipe_ingredient',
        e.toJson(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });

    final results = await batch.commit();

    return recipeIngredient.length == results.length;
  }
}
