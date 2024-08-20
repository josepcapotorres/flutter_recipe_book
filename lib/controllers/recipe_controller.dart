import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_myrecipesapp/controllers/calendar_controller.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/models/models.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../db/db.dart';
import 'base_controller.dart';

// TODO: Refactor brutal de mètodes d'importació i exportació. Segurament amb dos mètodes es pot fer tot

class RecipeController extends BaseController {
  List<Recipe> recipeList = [];
  bool loading = true;
  Recipe? randomRecipe;
  final _ingredientsFileName = "ingredients.json";
  final _recipesFileName = "recipes.json";
  final _foodCategoriesFileName = "food_categories.json";
  final _mealsFileName = "meals.json";
  final _recipeMealsFileName = "recipe_meals.json";
  final _recipeIngredientsFileName = "recipe_ingredients.json";
  final _calendarFileName = "calendar.json";
  late IngredientTable _ingredientManager;
  late RecipeTable _recipeManager;
  late FoodCategoryTable _foodCategoryManager;
  late MealTable _mealManager;
  late RecipeMealTable _recipeMealManager;
  late RecipeIngredientTable _recipeIngredientManager;
  late CalendarTable _calendarManager;

  @override
  void onInit() {
    super.onInit();

    _recipeManager = Get.find<RecipeTable>();
    _foodCategoryManager = Get.find<FoodCategoryTable>();
    _mealManager = Get.find<MealTable>();
    _ingredientManager = Get.find<IngredientTable>();
    _recipeIngredientManager = Get.find<RecipeIngredientTable>();
    _calendarManager = Get.find<CalendarTable>();
    _recipeMealManager = Get.find<RecipeMealTable>();
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

    await fetchRecipeList();

    final recipeDateInCalendar =
        await calendarCtrl.getDateIfRecipeInCalendarBetweenDates(
      recipeId: recipeId,
    );

    if (recipeDateInCalendar != null) {
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
      // Ingredients
      final ingredientsFile = File(
          "${appExportDir.path}${Platform.pathSeparator}$_ingredientsFileName");

      if (await ingredientsFile.exists()) {
        await ingredientsFile.delete();
      }

      // Food categories
      final foodCategoriesFile = File(
        "${appExportDir.path}${Platform.pathSeparator}$_foodCategoriesFileName",
      );

      if (await foodCategoriesFile.exists()) {
        await foodCategoriesFile.delete();
      }

      // Recipes
      final recipesFile = File(
        "${appExportDir.path}${Platform.pathSeparator}$_recipesFileName",
      );

      if (await recipesFile.exists()) {
        await recipesFile.delete();
      }

      // Recipe ingredients
      final recipeIngredientsFile = File(
        "${appExportDir.path}${Platform.pathSeparator}$_recipeIngredientsFileName",
      );

      if (await recipeIngredientsFile.exists()) {
        await recipeIngredientsFile.delete();
      }

      // Meals
      final mealsFile = File(
        "${appExportDir.path}${Platform.pathSeparator}$_mealsFileName",
      );

      if (await mealsFile.exists()) {
        await mealsFile.delete();
      }

      // Recipe meals
      final recipeMealsFile = File(
        "${appExportDir.path}${Platform.pathSeparator}$_recipeMealsFileName",
      );

      if (await recipeMealsFile.exists()) {
        await recipeMealsFile.delete();
      }

      // Calendar
      final calendarFile = File(
        "${appExportDir.path}${Platform.pathSeparator}$_calendarFileName",
      );

      if (await calendarFile.exists()) {
        await calendarFile.delete();
      }
    }

    await _exportIngredients(appExportDir, _ingredientsFileName);
    await _exportFoodCategories(appExportDir, _foodCategoriesFileName);
    await _exportRecipes(appExportDir, _recipesFileName);
    await _exportRecipeIngredients(appExportDir, _recipeIngredientsFileName);
    await _exportMeals(appExportDir, _mealsFileName);
    await _exportRecipeMeals(appExportDir, _recipeMealsFileName);
    await _exportCalendar(appExportDir, _calendarFileName);
  }

  Future<void> _exportIngredients(
      Directory appDownloadDir, String ingredientsFileName) async {
    final ingredients = await _ingredientManager.getIngredients();
    final ingredientsMap = ingredients.map((e) => e.toJson()).toList();
    final file = File(
      "${appDownloadDir.path}${Platform.pathSeparator}$ingredientsFileName",
    );

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(ingredientsMap));
  }

  Future<void> _exportRecipes(
      Directory appDownloadDir, String recipesFileName) async {
    final recipes = await _recipeManager.getRecipes();
    final recipesMap = recipes.map((e) => e.toJson()).toList();
    final file = File(
      "${appDownloadDir.path}${Platform.pathSeparator}$recipesFileName",
    );

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(recipesMap));
  }

  Future<void> _exportRecipeIngredients(
      Directory appDownloadDir, String recipeIngredientsFileName) async {
    final recipeIngredients =
        await _recipeIngredientManager.getRecipeIngredients();
    final recipeIngredientsMap =
        recipeIngredients.map((e) => e.toJson()).toList();
    final file = File(
      "${appDownloadDir.path}${Platform.pathSeparator}$recipeIngredientsFileName",
    );

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(recipeIngredientsMap));
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

  Future<void> _exportCalendar(
      Directory appDownloadDir, String calendarFileName) async {
    final calendarMap = await _calendarManager.getCalendar();
    final file = File(
      "${appDownloadDir.path}${Platform.pathSeparator}$calendarFileName",
    );

    if (!await file.exists()) {
      await file.create();
    }

    file.writeAsString(jsonEncode(calendarMap));
  }

  Future<void> importData() async {
    final importExportDir = await _getImportExportDir();
    final appImportExportDir = Directory("${importExportDir!.path}");

    await _importIngredients(appImportExportDir, _ingredientsFileName);
    await _importFoodCategories(appImportExportDir, _foodCategoriesFileName);
    await _importRecipes(appImportExportDir, _recipesFileName);
    await _importRecipeIngredients(
      appImportExportDir,
      _recipeIngredientsFileName,
    );
    await _importMeals(appImportExportDir, _mealsFileName);
    await _importRecipeMeals(appImportExportDir, _recipeMealsFileName);
    await _importCalendar(appImportExportDir, _calendarFileName);
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
      print("Cannot get download folder path. Error: $err. Stacktrace: $stack");
    }

    return directory;
  }

  Future<void> _importIngredients(
      Directory appDownloadDir, String ingredientsFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$ingredientsFileName";
    final ingredientsFile = File(importPath);

    if (!await ingredientsFile.exists()) {
      Get.rawSnackbar(message: "El fitxer ${ingredientsFile.path} no existeix");
      return;
    }

    // Get ingredients from db
    final ingredientsFromDb = await _ingredientManager.getIngredients();

    // Get ingredients from the exported file
    final ingredientsFileContent = await ingredientsFile.readAsString();
    final ingredientsMapFromFile = jsonDecode(ingredientsFileContent) as List;
    final ingredientsFromFile =
        ingredientsMapFromFile.map((e) => Ingredient.fromJson(e)).toList();

    for (final currIngredientFromFile in ingredientsFromFile) {
      if (!ingredientsFromDb.contains(currIngredientFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result =
            await _ingredientManager.newIngredient(currIngredientFromFile);
        print("Àpat ${currIngredientFromFile.name} creat? $result");
      }
    }
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

  Future<void> _importRecipeIngredients(
      Directory appDownloadDir, String recipeIngredientsFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$recipeIngredientsFileName";
    final recipeIngredientsFile = File(importPath);

    if (!await recipeIngredientsFile.exists()) {
      Get.rawSnackbar(
          message: "El fitxer ${recipeIngredientsFile.path} no existeix");
      return;
    }

    // Get recipeIngredients from db
    final recipeIngredientsFromDb =
        await _recipeIngredientManager.getRecipeIngredients();

    // Get recipeIngredients from the exported file
    final recipeIngredientsFileContent =
        await recipeIngredientsFile.readAsString();
    final recipeIngredientsMapFromFile =
        jsonDecode(recipeIngredientsFileContent) as List;
    final recipeIngredientsFromFile = recipeIngredientsMapFromFile
        .map((e) => RecipeIngredient.fromJson(e))
        .toList();

    for (final currRecipeIngredientFromFile in recipeIngredientsFromFile) {
      if (!recipeIngredientsFromDb.contains(currRecipeIngredientFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await _recipeIngredientManager.newRecipeIngredient(
          [currRecipeIngredientFromFile],
        );
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

  Future<void> _importCalendar(
      Directory appDownloadDir, String calendarFileName) async {
    final importPath =
        "${appDownloadDir.path}${Platform.pathSeparator}$calendarFileName";
    final calendarFile = File(importPath);

    if (!await calendarFile.exists()) {
      Get.rawSnackbar(message: "El fitxer ${calendarFile.path} no existeix");
      print("El fitxer ${calendarFile.path} no existeix");
      return;
    }

    // Get calendar from db
    final calendarFromDb = await _calendarManager.getCalendar();

    // Get calendar from the exported file
    final calendarFileContent = await calendarFile.readAsString();
    final calendarFromFile = jsonDecode(calendarFileContent) as List;
    /*final calendarFromFile =
    recipeMealsMapFromFile.map((e) => RecipeMeal.fromJson(e)).toList();*/

    for (final calendarFromFile in calendarFromFile) {
      if (!calendarFromDb.contains(calendarFromFile)) {
        // Insert the element that's in the exported file, but not in the local db
        final result = await _calendarManager.insertCalendarLine(
          calendarFromFile,
        );
      }
    }
  }
}
