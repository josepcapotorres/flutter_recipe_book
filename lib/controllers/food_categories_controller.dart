import 'package:flutter_myrecipesapp/controllers/base_controller.dart';
import 'package:flutter_myrecipesapp/controllers/database_controller.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_translate/flutter_translate.dart';

class FoodCategoriesController extends BaseController {
  List<FoodCategory> categories = [];
  bool loading = true;

  void fetchFoodCategories({int recipeId = 0}) async {
    /*loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));*/

    if (recipeId == 0) {
      categories = await DBController.instance.getFoodCategories();
    } else {
      categories =
          await DBController.instance.getFoodCategoriesByRecipeId(recipeId);
    }

    final noFiltedCategory = FoodCategory();
    noFiltedCategory
      ..id = 0
      ..name = translate("common.no_specified");

    categories.insert(0, noFiltedCategory);

    loading = false;

    update();
  }

  void newFoodCategory(FoodCategory foodCategory) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newCategoryResult =
        await DBController.instance.newFoodCategory(foodCategory);

    if (newCategoryResult) {
      final dbCategories = await DBController.instance.getFoodCategories();

      categories = dbCategories;
    }

    loading = false;

    update();
  }

  void deleteFoodCategory(int categoryId) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    final newCategoryResult =
        await DBController.instance.deleteFoodCategory(categoryId);

    if (newCategoryResult) {
      final dbCategories = await DBController.instance.getFoodCategories();

      categories = dbCategories;
    }

    loading = false;

    update();
  }

  void updateFoodCategory(FoodCategory foodCategory) async {
    loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));

    try {
      final updatedResult =
          await DBController.instance.updateFoodCategory(foodCategory);

      if (updatedResult) {
        final dbCategories = await DBController.instance.getFoodCategories();

        categories = dbCategories;
      }
    } catch (e) {
      print(e);
    }

    loading = false;

    update();
  }
}
