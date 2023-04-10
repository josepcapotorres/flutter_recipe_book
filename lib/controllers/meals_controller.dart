import 'package:flutter_myrecipesapp/controllers/base_controller.dart';
import 'package:flutter_myrecipesapp/db/db.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class MealsController extends BaseController {
  late MealTable _mealTable;
  List<Meal> meals = [];
  List<Meal> selectedMeals = [];
  bool loading = true;

  @override
  void onInit() {
    super.onInit();

    _mealTable = Get.find<MealTable>();
  }

  void fetchMeals({int recipeId = 0}) async {
    meals = await getMeals(recipeId: recipeId);

    loading = false;

    update();
  }

  Future<List<Meal>> getMeals({int recipeId = 0}) async {
    List<Meal> meals;

    if (recipeId == 0) {
      meals = await _mealTable.getMeals();
    } else {
      meals = await _mealTable.getMealsByRecipeId(recipeId);
    }

    final noFilterMeal = Meal();
    noFilterMeal
      ..id = 0
      ..name = translate("common.no_specified");

    meals.insert(0, noFilterMeal);

    return meals;
  }

  void newMeal(Meal meal) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newMealResult = await _mealTable.newMeal(meal);

    if (newMealResult) {
      final dbMeals = await _mealTable.getMeals();

      meals = dbMeals;
    }

    loading = false;

    update();
  }

  void deleteMeal(int mealId) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newMealResult = await _mealTable.deleteMeal(mealId);

    if (newMealResult) {
      final dbMeals = await _mealTable.getMeals();

      meals = dbMeals;
    }

    loading = false;

    update();
  }

  Future<bool> deleteMealsByRecipeId(int recipeId) async {
    final mealResult = await _mealTable.deleteMealsByRecipeId(recipeId);

    return mealResult;
  }

  void updateMeal(Meal meal) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    try {
      final updatedResult = await _mealTable.updateMeal(meal);

      if (updatedResult) {
        final dbMeals = await _mealTable.getMeals();

        meals = dbMeals;
      }
    } catch (e) {
      print(e);
    }

    loading = false;

    update();
  }

  Future<bool> insertRecipeMeals(int recipeId, List<Meal> selectedMeals) async {
    loading = true;
    bool result = false;

    update();

    await Future.delayed(Duration(seconds: 1));

    try {
      result = await _mealTable.insertRecipeMeals(recipeId, selectedMeals);
      print("");
    } catch (e) {
      print(e);
    }

    loading = false;

    update();

    return result;
  }

  bool isMealFieldValidated() {
    return meals.where((e) => e.selected).toList().isNotEmpty;
  }

  Future<void> changeMealOrder({
    required Meal oldMeal,
    required Meal newMeal,
  }) async {
    await _mealTable.changeMealOrder(oldMeal, newMeal);
  }
}
