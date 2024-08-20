import 'package:flutter_myrecipesapp/db/tables/ingredient_table.dart';
import 'package:flutter_myrecipesapp/models/models.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class IngredientController extends GetxController {
  late IngredientTable _ingredientTable;
  List<Ingredient> ingredients = [];

  bool loading = true;

  @override
  void onInit() {
    super.onInit();

    _ingredientTable = Get.find<IngredientTable>();
  }

  void getIngredientsByRecipeId(int recipeId) async {
    loading = true;
    update();

    ingredients = await _ingredientTable.getIngredientsByRecipeId(recipeId);

    loading = false;
    update();
  }

  void getIngredientsByName({
    int? recipeId,
    required String ingName,
  }) async {
    loading = true;
    update();

    ingredients =
        await _ingredientTable.getIngredientsByName(recipeId, ingName);

    loading = false;
    update();
  }

  void getIngredients() async {
    loading = true;
    update();

    ingredients = await _ingredientTable.getIngredients();

    loading = false;
    update();
  }

  String? validateEmptyField(String? text) {
    if (text == null) {
      return translate("validations.unknown_error");
    } else if (text.isNotEmpty) {
      return null;
    } else {
      return translate("validations.empty_field");
    }
  }

  void deleteIngredient(int ingredientId) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newMealResult = await _ingredientTable.deleteIngredient(ingredientId);

    if (newMealResult) {
      final dbIngs = await _ingredientTable.getIngredients();

      ingredients = dbIngs;
    }

    loading = false;

    update();
  }

  Future<void> updateMeal(Ingredient ingredient) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    try {
      final updatedResult = await _ingredientTable.updateIngredient(ingredient);

      if (updatedResult) {
        final dbIngredients = await _ingredientTable.getIngredients();

        ingredients = dbIngredients;
      }
    } catch (e) {
      print(e);
    }

    loading = false;

    update();
  }

  Future<void> newIngredient(Ingredient ingredient) async {
    loading = true;
    update();

    final newIngResult = await _ingredientTable.newIngredient(ingredient);

    if (newIngResult) {
      final dbIngs = await _ingredientTable.getIngredients();

      ingredients = dbIngs;
    }

    loading = false;
    update();
  }
}
