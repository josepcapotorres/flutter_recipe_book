import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/food_categories_controller.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/controllers/recipe_controller.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe.dart';
import 'package:flutter_myrecipesapp/views/pages/recipe_detail_page.dart';
import 'package:flutter_myrecipesapp/views/widgets/are_you_sure_dialog.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import '../../helpers/app_colors.dart';

class RecipesListPage extends StatelessWidget /*with WidgetsBindingObserver*/ {
  static final routeName = "recipes_list";

  final _recipeController = Get.find<RecipeController>();
  final _mealsController = Get.find<MealsController>();
  final _foodCategoriesCtrl = Get.find<FoodCategoriesController>();
  Meal? _selectedMeal;
  FoodCategory? _selectedCategory;

  RecipesListPage() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: AppBar(
        title: Text(translate("recipes_list_page.title")),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () async {
              _recipeController.showLoadingDialog(
                message: translate("recipes_list_page.exporting_data"),
              );

              await _recipeController.exportData();

              _recipeController.hideLoadingDialog();

              Get.rawSnackbar(
                message: translate("recipes_list_page.data_exported"),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () async {
              _recipeController.showLoadingDialog(
                message: translate("recipes_list_page.importing_data"),
              );

              await _recipeController.importData();

              _recipeController.hideLoadingDialog();

              Get.rawSnackbar(
                message: translate("recipes_list_page.data_imported"),
                duration: Duration(seconds: 2),
              );

              _recipeController.fetchRecipeList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          GetBuilder<MealsController>(
            builder: (_) => _MealDropdownList(
              _mealsController.meals,
              onChanged: (value) {
                _selectedMeal = value;
              },
            ),
          ),
          GetBuilder<FoodCategoriesController>(
            builder: (_) => _FoodTypeList(
              _foodCategoriesCtrl.categories,
              onChanged: (value) {
                _selectedCategory = value;
              },
            ),
          ),
          Expanded(
            child: GetBuilder<RecipeController>(
              builder: (_) => _recipeController.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _recipeController.recipeList.isNotEmpty
                      ? _RecipeList(recipeList: _recipeController.recipeList)
                      : Center(
                          child: Text(translate("common.no_results")),
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Get.toNamed(RecipeDetailPage.routeName),
      ),
    );
  }

  void _loadData() {
    _recipeController.fetchRecipeList();
    _foodCategoriesCtrl.fetchFoodCategories();
    _mealsController.fetchMeals();
  }
}

class _MealDropdownList extends StatefulWidget {
  final List<Meal> meals;
  final Function(Meal) onChanged;

  _MealDropdownList(this.meals, {required this.onChanged});

  @override
  _MealDropdownListState createState() => _MealDropdownListState();
}

class _MealDropdownListState extends State<_MealDropdownList> {
  Meal? _selectedMeal;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Meal>(
      isExpanded: true,
      hint: Text(
        translate("recipes_list_page.select_meal"),
        style: TextStyle(color: Color(0xFF9F9F9F)),
      ),
      value: _selectedMeal,
      items: widget.meals
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedMeal = newValue;
          widget.onChanged(newValue!);
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        focusColor: AppColors.primaryColor,
      ),
    );
  }
}

class _FoodTypeList extends StatefulWidget {
  final List<FoodCategory> categories;
  final Function(FoodCategory) onChanged;

  _FoodTypeList(this.categories, {required this.onChanged});

  @override
  _FoodTypeListState createState() => _FoodTypeListState();
}

class _FoodTypeListState extends State<_FoodTypeList> {
  FoodCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<FoodCategory>(
      isExpanded: true,
      hint: Text(
        translate("recipes_list_page.select_category"),
        style: TextStyle(color: Color(0xFF9F9F9F)),
      ),
      value: _selectedCategory,
      items: widget.categories
          .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e.name),
              ))
          .toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedCategory = newValue!;
          widget.onChanged(newValue);
        });
      },
    );
  }
}

class _RecipeList extends StatelessWidget {
  final List<Recipe> recipeList;
  final _recipeController = Get.find<RecipeController>();

  _RecipeList({required this.recipeList});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: recipeList
          .map((e) => _ListItem(
                title: (e.name!),
                onDelete: () async {
                  final success = await _recipeController.deleteRecipe(e.id!);

                  Get.back();

                  if (success) {
                    Get.rawSnackbar(
                      message: translate(
                        "recipes_list_page.recipe_deleted_successfuly",
                      ),
                    );
                  } else {
                    Get.rawSnackbar(
                      message: translate(
                        "recipes_list_page.error_delete_recipe",
                      ),
                    );
                  }
                },
                onTap: () {
                  Get.toNamed(
                    RecipeDetailPage.routeName,
                    arguments: e,
                  );
                },
              ))
          .toList(),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  _ListItem({
    required this.title,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = 36.0;

    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.clear, size: iconSize),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AreYouSureDialog(
                    onYes: onDelete,
                    onNo: () => Get.back(),
                  );
                },
              );
            },
          ),
          SizedBox(width: 10),
          Icon(Icons.keyboard_arrow_right, size: iconSize),
        ],
      ),
      onTap: onTap,
    );
  }
}
