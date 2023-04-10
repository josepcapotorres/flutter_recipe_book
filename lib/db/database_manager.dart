import 'dart:io';

import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe_meal.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  final String _dbName = "my_recipes.db";
  final int _dbVersion = 1;

  // make this a singleton class
  //DBController._privateConstructor();
  //static final DBController instance = DBController._privateConstructor();

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
        order_index INTEGER,
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

    await db.execute("""
      CREATE TABLE calendar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        meal_id INTEGER,
        date DATETIME,
        FOREIGN KEY (recipe_id) REFERENCES recipe(id)
        FOREIGN KEY (meal_id) REFERENCES meal(id)
      )
    """);

    await db.execute(
        "INSERT INTO meal (name, order_index) VALUES ('${translate("database.breakfast")}', 1)");
    await db.execute(
        "INSERT INTO meal (name, order_index) VALUES ('${translate("database.lunch")}', 2)");
    await db.execute(
        "INSERT INTO meal (name, order_index) VALUES ('${translate("database.dinner")}', 3)");

    await db.execute(
        "INSERT INTO food_category (name) VALUES ('${translate("database.fish")}')");
    await db.execute(
        "INSERT INTO food_category (name) VALUES ('${translate("database.pasta")}')");
    await db.execute(
        "INSERT INTO food_category (name) VALUES ('${translate("database.meat")}')");
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
}
