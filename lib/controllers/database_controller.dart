import 'dart:io';

import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe.dart';
import 'package:flutter_myrecipesapp/models/recipe_meal.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBController {
  final String _dbName = "my_recipes.db";
  final int _dbVersion = 1;

  // make this a singleton class
  DBController._privateConstructor();
  static final DBController instance = DBController._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE recipe (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            n_persons INTEGER NOT NULL,
            ings_and_quants TEXT NOT NULL,
            steps_reproduce TEXT NOT NULL,
            food_category_id INTEGER,
            FOREIGN KEY(food_category_id) REFERENCES food_category(id)
          )
          ''');
    await db.execute('''
      CREATE TABLE meal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipe_meal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealId INTEGER,
        recipeId INTEGER,
        FOREIGN KEY(mealId) REFERENCES meal(id),
        FOREIGN KEY(recipeId) REFERENCES recipe(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE food_category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute(
        "INSERT INTO meal (name) VALUES ('${translate("database.breakfast")}')");
    await db.execute(
        "INSERT INTO meal (name) VALUES ('${translate("database.lunch")}')");
    await db.execute(
        "INSERT INTO meal (name) VALUES ('${translate("database.dinner")}')");

    await db.execute(
        "INSERT INTO food_category (name) VALUES ('${translate("database.fish")}')");
    await db.execute(
        "INSERT INTO food_category (name) VALUES ('${translate("database.pasta")}')");
    await db.execute(
        "INSERT INTO food_category (name) VALUES ('${translate("database.meat")}')");
  }

  Future<List<Recipe>> getRecipes() async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.query("recipe");

    if (results == null) {
      results = [];
    }

    return results.map((e) => Recipe.fromJson(e)).toList();
  }

  Future<int> newRecipe(Recipe recipe) async {
    final db = await database;

    final result = await db?.insert("recipe", recipe.toJson()) ?? 0;

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

  Future<List<FoodCategory>> getFoodCategories({int recipeId = 0}) async {
    final db = await database;

    List<Map<String, Object?>>? results;

    if (recipeId == 0) {
      results = await db?.query("food_category");
    } else {
      results = await db?.query("food_category");
    }

    if (results == null) {
      results = [];
    }

    return results.map((e) => FoodCategory.fromJson(e)).toList();
  }

  Future<List<FoodCategory>> getFoodCategoriesByRecipeId(int recipeId) async {
    final categories = await getFoodCategories();
    final recipes = await getRecipes();
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

    final result =
        await db?.insert("food_category", foodCategory.toJson()) ?? 0;

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

  Future<List<Meal>> getMeals() async {
    final db = await database;

    List<Map<String, Object?>>? results = await db?.query("meal");

    if (results == null) {
      results = [];
    }

    return results.map((e) => Meal.fromJson(e)).toList();
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

  Future<bool> deleteMealsByRecipeId(int recipeId) async {
    final db = await database;

    try {
      await db?.delete(
        "recipe_meal",
        where: "recipeId = ?",
        whereArgs: [recipeId],
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> insertRecipeMeals(int recipeId, List<Meal> meals) async {
    final db = await database;
    int? result;

    for (final meal in meals) {
      final recipeMeal = RecipeMeal();
      recipeMeal.mealId = meal.id!;
      recipeMeal.recipeId = recipeId;

      try {
        result = await db?.insert("recipe_meal", recipeMeal.toJson());
      } catch (e) {
        print(e);
      }
      // If theres an error on insert any db row, we won`t keep operating
      if (result == 0) {
        return false;
      }
    }

    // If meal list is empty, result will be null
    return result != null;
  }

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
