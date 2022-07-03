import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_myrecipesapp/controllers/database_controller.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe.dart';
import 'package:flutter_myrecipesapp/models/recipe_meal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import 'base_controller.dart';

class RecipeController extends BaseController {
  List<Recipe> recipeList = [];
  bool loading = true;
  Recipe? randomRecipe;
  final _recipesFileName = "recipes.json";
  final _foodCategoriesFileName = "food_categories.json";
  final _mealsFileName = "meals.json";
  final _recipeMealFileName = "recipe_meals.json";

  Future<void> fetchRecipeList() async {
    await Future.delayed(Duration(seconds: 1));
    loading = false;

    recipeList = await DBController.instance.getRecipes();

    update();
  }

  Future<int> newRecipe(Recipe recipe) async {
    int result;

    try {
      result = await DBController.instance.newRecipe(recipe);
    } catch (e) {
      result = 0;
    }

    return result;
  }

  Future<bool> deleteRecipe(int recipeId) async {
    final success = await DBController.instance.deleteRecipe(recipeId);

    if (success) {
      fetchRecipeList();
    }

    return success;
  }

  void generateRandomRecipe() async {
    await fetchRecipeList();

    if (recipeList.isNotEmpty) {
      final randNum = generateRandomNumber(recipeList.length - 1);

      if (recipeList.length - 1 >= randNum) {
        randomRecipe = recipeList[randNum];
      }
    }

    loading = false;
    update();
  }

  int generateRandomNumber(int max) {
    final random = Random();

    int r = random.nextInt(max);

    return r;
  }

  Future<void> exportData() async {
    final exportDir = await getExternalStorageDirectory();
    final appExportDir = Directory("${exportDir!.path}");

    if (!await appExportDir.exists()) {
      await appExportDir.create();
    } else {
      final recipesFile = File(
          "${appExportDir.path}${Platform.pathSeparator}$_recipesFileName");

      if (await recipesFile.exists()) {
        await recipesFile.delete();
      }

      final foodCategoriesFile = File(
          "${appExportDir.path}${Platform.pathSeparator}$_foodCategoriesFileName");

      if (await foodCategoriesFile.exists()) {
        await foodCategoriesFile.delete();
      }

      final mealsFile =
          File("${appExportDir.path}${Platform.pathSeparator}$_mealsFileName");

      if (await mealsFile.exists()) {
        await mealsFile.delete();
      }
    }

    await _exportRecipes(appExportDir, _recipesFileName);
    await _exportFoodCategories(appExportDir, _foodCategoriesFileName);
    await _exportMeals(appExportDir, _mealsFileName);
    await _exportRecipeMeals(appExportDir, _recipeMealFileName);
  }

  Future<void> _exportRecipes(
      Directory appDownloadDir, String recipesFileName) async {
    final recipes = await DBController.instance.getRecipes();
    final recipesMap = recipes.map((e) => e.toJson()).toList();
    final file =
        File("${appDownloadDir.path}${Platform.pathSeparator}$recipesFileName");

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(recipesMap));
  }

  Future<void> _exportFoodCategories(
      Directory appDownloadDir, String foodCategoriesFileName) async {
    final foodCategories = await DBController.instance.getFoodCategories();
    final foodCategoriesMap = foodCategories.map((e) => e.toJson()).toList();
    final file = File(
        "${appDownloadDir.path}${Platform.pathSeparator}$foodCategoriesFileName");

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(foodCategoriesMap));
  }

  Future<void> _exportMeals(
      Directory appDownloadDir, String mealsFileName) async {
    final meals = await DBController.instance.getMeals();
    final mealsMap = meals.map((e) => e.toJson()).toList();
    final file =
        File("${appDownloadDir.path}${Platform.pathSeparator}$mealsFileName");

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(mealsMap));
  }

  Future<void> _exportRecipeMeals(
      Directory appDownloadDir, String recipeMealsFileName) async {
    final recipeMeals = await DBController.instance.getRecipeMeals();
    final recipeMealsMap = recipeMeals.map((e) => e.toJson()).toList();
    final file = File(
        "${appDownloadDir.path}${Platform.pathSeparator}$recipeMealsFileName");

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(recipeMealsMap));
  }

  Future<void> importData() async {
    final exportDir = await getExternalStorageDirectory();
    final appExportDir = Directory("${exportDir!.path}");

    await _importRecipes(appExportDir, _recipesFileName);
    await _importFoodCategories(appExportDir, _foodCategoriesFileName);
    await _importMeals(appExportDir, _mealsFileName);
    await _importRecipeMeals(appExportDir, _recipeMealFileName);
  }

  Future<void> _importFoodCategories(
      Directory appDownloadDir, String foodCategoriesFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$foodCategoriesFileName";
    final categoriesFile = File(importPath);

    if (!await categoriesFile.exists()) {
      Get.rawSnackbar(message: "El fitxer ${categoriesFile.path} no existeix");
      return;
    }

    // Get categories from db
    final categoriesFromDb = await DBController.instance.getFoodCategories();

    // Get categories from the exported file
    final categoriesFileContent = await categoriesFile.readAsString();
    final categoriesMapFromFile = jsonDecode(categoriesFileContent) as List;
    final categoriesFromFile =
        categoriesMapFromFile.map((e) => FoodCategory.fromJson(e)).toList();

    for (final currCatFromFile in categoriesFromFile) {
      if (!categoriesFromDb.contains(currCatFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result =
            await DBController.instance.newFoodCategory(currCatFromFile);
        print("Categoria ${currCatFromFile.name} creat? $result");
      }
    }
  }

  Future<void> _importMeals(
      Directory appDownloadDir, String foodMealsFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$foodMealsFileName";
    final mealsFile = File(importPath);

    if (!await mealsFile.exists()) {
      Get.rawSnackbar(message: "El fitxer ${mealsFile.path} no existeix");
      return;
    }

    // Get meals from db
    final mealsFromDb = await DBController.instance.getMeals();

    // Get meals from the exported file
    final mealsFileContent = await mealsFile.readAsString();
    final mealsMapFromFile = jsonDecode(mealsFileContent) as List;
    final mealsFromFile =
        mealsMapFromFile.map((e) => Meal.fromJson(e)).toList();

    for (final currMealFromFile in mealsFromFile) {
      if (!mealsFromDb.contains(currMealFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await DBController.instance.newMeal(currMealFromFile);
        print("Àpat ${currMealFromFile.name} creat? $result");
      }
    }
  }

  Future<void> _importRecipes(
      Directory appDownloadDir, String recipesFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$recipesFileName";
    final recipesFile = File(importPath);

    if (!await recipesFile.exists()) {
      Get.rawSnackbar(message: "El fitxer ${recipesFile.path} no existeix");
      return;
    }

    // Get categories from db
    final recipesFromDb = await DBController.instance.getRecipes();

    // Get recipes from the exported file
    final recipesFileContent = await recipesFile.readAsString();
    final recipesMapFromFile = jsonDecode(recipesFileContent) as List;
    final recipesFromFile =
        recipesMapFromFile.map((e) => Recipe.fromJson(e)).toList();

    for (final currRecipeFromFile in recipesFromFile) {
      if (!recipesFromDb.contains(currRecipeFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result =
            await DBController.instance.newRecipe(currRecipeFromFile);

        print("Recepta ${currRecipeFromFile.name} creada? ${result == 1}");
      }
    }
  }

  Future<void> _importRecipeMeals(
      Directory appDownloadDir, String recipeMealFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$recipeMealFileName";
    final recipeMealsFile = File(importPath);

    if (!await recipeMealsFile.exists()) {
      Get.rawSnackbar(message: "El fitxer ${recipeMealsFile.path} no existeix");
      print("El fitxer ${recipeMealsFile.path} no existeix");
      return;
    }

    // Get categories from db
    final recipeMealsFromDb = await DBController.instance.getRecipeMeals();

    // Get recipes from the exported file
    final recipeMealsFileContent = await recipeMealsFile.readAsString();
    final recipeMealsMapFromFile = jsonDecode(recipeMealsFileContent) as List;
    final recipeMealsFromFile =
        recipeMealsMapFromFile.map((e) => RecipeMeal.fromJson(e)).toList();

    for (final currRecipeMealFromFile in recipeMealsFromFile) {
      if (!recipeMealsFromDb.contains(currRecipeMealFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await DBController.instance
            .insertRecipeMeal(currRecipeMealFromFile);

        print(
            "RecipeMeal ${jsonEncode(currRecipeMealFromFile.toJson())} creat? $result");
      }
    }
  }
}
