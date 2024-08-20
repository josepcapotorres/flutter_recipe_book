import 'package:flutter_myrecipesapp/models/models.dart';
import 'package:get/get.dart';

import '../db/tables/recipe_ingredient_table.dart';

class RecipeIngredientController extends GetxController {
  late RecipeIngredientTable _recipeIngredientTable;
  List<RecipeIngredient> recipeIngredients = [];
  bool loading = false;

  @override
  void onInit() {
    super.onInit();

    _recipeIngredientTable = Get.find<RecipeIngredientTable>();
  }

  void getRecipeIngredientsByRecipeId(int recipeId) async {
    loading = true;
    update();

    recipeIngredients =
        await _recipeIngredientTable.getIngredientsByRecipeId(recipeId);

    loading = false;
    update();
  }

  void fillRecipeId(int recipeId) {
    recipeIngredients.map((e) {
      e.idRecipe = recipeId;

      return e;
    }).toList();
  }

  void refreshScreen() {
    update();
  }

  void removeIngredient(int indexToRemove) {
    recipeIngredients.removeAt(indexToRemove);

    update();
  }

  ///
  /// List of ingredients are already stored/managed in this controller
  ///
  Future<bool> newRecipeIngredients() async {
    loading = true;
    update();

    final result =
        await _recipeIngredientTable.newRecipeIngredient(recipeIngredients);

    loading = false;
    update();

    return result;
  }
}
