import 'package:flutter_myrecipesapp/controllers/base_controller.dart';
import 'package:flutter_myrecipesapp/db/db.dart';
//import 'package:flutter_myrecipesapp/db/database_manager.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class FoodCategoriesController extends BaseController {
  late FoodCategoryTable _foodCategoryManager;
  List<FoodCategory> categories = [];
  bool loading = true;

  @override
  void onInit() {
    super.onInit();

    _foodCategoryManager = Get.find<FoodCategoryTable>();
  }

  void fetchFoodCategories({int recipeId = 0}) async {
    /*loading = true;

    update();

    await Future.delayed(Duration(seconds: 1));*/

    if (recipeId == 0) {
      categories = await _foodCategoryManager.getFoodCategories();
    } else {
      categories =
          await _foodCategoryManager.getFoodCategoriesByRecipeId(recipeId);
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
        await _foodCategoryManager.newFoodCategory(foodCategory);

    if (newCategoryResult) {
      final dbCategories = await _foodCategoryManager.getFoodCategories();

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
        await _foodCategoryManager.deleteFoodCategory(categoryId);

    if (newCategoryResult) {
      final dbCategories = await _foodCategoryManager.getFoodCategories();

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
          await _foodCategoryManager.updateFoodCategory(foodCategory);

      if (updatedResult) {
        final dbCategories = await _foodCategoryManager.getFoodCategories();

        categories = dbCategories;
      }
    } catch (e) {
      print(e);
    }

    loading = false;

    update();
  }
}
