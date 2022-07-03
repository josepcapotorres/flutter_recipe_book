import 'package:flutter_myrecipesapp/controllers/base_controller.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:get/get.dart';

import 'database_controller.dart';

class MealsController extends BaseController {
  List<Meal> meals = [];
  List<Meal> selectedMeals = [];
  bool loading = true;

  void fetchMeals({int recipeId = 0}) async {
    /*loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));*/

    if (recipeId == 0) {
      meals = await DBController.instance.getMeals();
    } else {
      meals = await DBController.instance.getMealsByRecipeId(recipeId);
    }

    loading = false;

    update();
  }

  void newMeal(Meal meal) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newMealResult = await DBController.instance.newMeal(meal);

    if (newMealResult) {
      final dbMeals = await DBController.instance.getMeals();

      meals = dbMeals;
    }

    loading = false;

    update();
  }

  void deleteMeal(int mealId) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newMealResult = await DBController.instance.deleteMeal(mealId);

    if (newMealResult) {
      final dbMeals = await DBController.instance.getMeals();

      meals = dbMeals;
    }

    loading = false;

    update();
  }

  Future<bool> deleteMealsByRecipeId(int recipeId) async {
    final mealResult =
        await DBController.instance.deleteMealsByRecipeId(recipeId);

    return mealResult;
  }

  void updateMeal(Meal meal) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    try {
      final updatedResult = await DBController.instance.updateMeal(meal);

      if (updatedResult) {
        final dbMeals = await DBController.instance.getMeals();

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
      result = await DBController.instance
          .insertRecipeMeals(recipeId, selectedMeals);
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
}
