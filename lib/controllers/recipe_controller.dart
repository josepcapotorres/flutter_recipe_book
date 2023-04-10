import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_myrecipesapp/controllers/calendar_controller.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe.dart';
import 'package:flutter_myrecipesapp/models/recipe_meal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../db/db.dart';
import 'base_controller.dart';

class RecipeController extends BaseController {
  List<Recipe> recipeList = [];
  bool loading = true;
  Recipe? randomRecipe;
  final _recipesFileName = "recipes.json";
  final _foodCategoriesFileName = "food_categories.json";
  final _mealsFileName = "meals.json";
  final _recipeMealFileName = "recipe_meals.json";
  late RecipeTable _recipeManager;
  late FoodCategoryTable _foodCategoryManager;
  late MealTable _mealManager;
  late RecipeMealTable _recipeMealManager;

  @override
  void onInit() {
    super.onInit();

    _recipeManager = Get.find<RecipeTable>();
    _foodCategoryManager = Get.find<FoodCategoryTable>();
    _mealManager = Get.find<MealTable>();
  }

  Future<void> fetchRecipeList() async {
    try {
      loading = true;
      update();

      await _getRecipeList();
      await Future.delayed(Duration(milliseconds: 500));

      loading = false;
      update();
    } catch (e) {
      print("");
    }
  }

  Future<void> _getRecipeList() async {
    final mealsController = Get.find<MealsController>();

    recipeList = await _recipeManager.getRecipes();

    for (int i = 0; i < recipeList.length; i++) {
      final recipeMeals = await mealsController.getMeals(
        recipeId: recipeList[i].id!,
      );

      final selectedMeals = recipeMeals.where((e) => e.selected).toList();
      recipeList[i].meals = selectedMeals;
    }
  }

  Future<Recipe?> getRecipeById(int recipeId) async {
    return await _recipeManager.getRecipeById(recipeId);
  }

  Future<int> newRecipe(Recipe recipe) async {
    int result;

    try {
      result = await _recipeManager.newRecipe(recipe);
    } catch (e) {
      result = 0;
    }

    return result;
  }

  Future<bool> deleteRecipe(int recipeId) async {
    final calendarCtrl = Get.find<CalendarController>();

    // It deletes recipe from recipe table
    final success = await _recipeManager.deleteRecipe(recipeId);

    if (!success) {
      return false;
    }

    fetchRecipeList();

    if (await calendarCtrl.isRecipeInCalendarBetweenDates(recipeId: recipeId)) {
      // It deletes recipe from calendar table
      final deleted = await calendarCtrl.deleteRecipeInCalendar(
        recipeId: recipeId,
      );

      if (!deleted) {
        return false;
      }
    }

    // It refreshes calendar data on the screen
    calendarCtrl.getCalendarData();

    return true;
  }

  void generateRandomRecipe() async {
    loading = true;
    update(["random_food"]);

    await Future.delayed(Duration(milliseconds: 500));
    await _getRecipeList();

    if (recipeList.isNotEmpty) {
      int recipeNumRows = recipeList.length == 1 ? 1 : recipeList.length - 1;

      final randNum = _generateRandomNumber(recipeNumRows);

      if (recipeList.length - 1 >= randNum) {
        randomRecipe = recipeList[randNum];
      }
    }

    loading = false;
    update(["random_food"]);
  }

  int _generateRandomNumber(int max) {
    final random = Random();

    int r = random.nextInt(max);

    return r;
  }

  Future<void> exportData() async {
    final exportDir = await _getImportExportDir();
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
    final recipes = await _recipeManager.getRecipes();
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
    final foodCategories = await _foodCategoryManager.getFoodCategories();
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
    final meals = await _mealManager.getMeals();
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
    final recipeMeals = await _recipeMealManager.getRecipeMeals();
    final recipeMealsMap = recipeMeals.map((e) => e.toJson()).toList();
    final file = File(
        "${appDownloadDir.path}${Platform.pathSeparator}$recipeMealsFileName");

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(recipeMealsMap));
  }

  Future<void> importData() async {
    final exportDir = await _getImportExportDir();
    final appExportDir = Directory("${exportDir!.path}");

    await _importRecipes(appExportDir, _recipesFileName);
    await _importFoodCategories(appExportDir, _foodCategoriesFileName);
    await _importMeals(appExportDir, _mealsFileName);
    await _importRecipeMeals(appExportDir, _recipeMealFileName);
  }

  Future<Directory?> _getImportExportDir() async {
    final appName = "RecipeBookApp";
    Directory? directory;

    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download/$appName');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }

    return directory;
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
    final categoriesFromDb = await _foodCategoryManager.getFoodCategories();

    // Get categories from the exported file
    final categoriesFileContent = await categoriesFile.readAsString();
    final categoriesMapFromFile = jsonDecode(categoriesFileContent) as List;
    final categoriesFromFile =
        categoriesMapFromFile.map((e) => FoodCategory.fromJson(e)).toList();

    for (final currCatFromFile in categoriesFromFile) {
      if (!categoriesFromDb.contains(currCatFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result =
            await _foodCategoryManager.newFoodCategory(currCatFromFile);
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
    final mealsFromDb = await _mealManager.getMeals();

    // Get meals from the exported file
    final mealsFileContent = await mealsFile.readAsString();
    final mealsMapFromFile = jsonDecode(mealsFileContent) as List;
    final mealsFromFile =
        mealsMapFromFile.map((e) => Meal.fromJson(e)).toList();

    for (final currMealFromFile in mealsFromFile) {
      if (!mealsFromDb.contains(currMealFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await _mealManager.newMeal(currMealFromFile);
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
    final recipesFromDb = await _recipeManager.getRecipes();

    // Get recipes from the exported file
    final recipesFileContent = await recipesFile.readAsString();
    final recipesMapFromFile = jsonDecode(recipesFileContent) as List;
    final recipesFromFile =
        recipesMapFromFile.map((e) => Recipe.fromJson(e)).toList();

    for (final currRecipeFromFile in recipesFromFile) {
      if (!recipesFromDb.contains(currRecipeFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await _recipeManager.newRecipe(currRecipeFromFile);

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
    final recipeMealsFromDb = await _recipeMealManager.getRecipeMeals();

    // Get recipes from the exported file
    final recipeMealsFileContent = await recipeMealsFile.readAsString();
    final recipeMealsMapFromFile = jsonDecode(recipeMealsFileContent) as List;
    final recipeMealsFromFile =
        recipeMealsMapFromFile.map((e) => RecipeMeal.fromJson(e)).toList();

    for (final currRecipeMealFromFile in recipeMealsFromFile) {
      if (!recipeMealsFromDb.contains(currRecipeMealFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await _recipeMealManager.insertRecipeMeal(
          currRecipeMealFromFile,
        );

        print(
          "RecipeMeal ${jsonEncode(currRecipeMealFromFile.toJson())} creat? $result",
        );
      }
    }
  }
}
