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

  @override
  Widget build(BuildContext context) {
    Future.microtask(() => _recipeController.fetchRecipeList());
    _foodCategoriesCtrl.fetchFoodCategories();
    _mealsController.fetchMeals();

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
                _recipeController.fetchRecipeList();
              },
            ),
          ),
          SizedBox(height: 15),
          GetBuilder<FoodCategoriesController>(
            builder: (_) => _FoodTypeList(
              _foodCategoriesCtrl.categories,
              onChanged: (value) {
                _selectedCategory = value;
                _recipeController.fetchRecipeList();
              },
            ),
          ),
          Expanded(
            child: GetBuilder<RecipeController>(
              builder: (_) {
                List<Recipe> recipesToShow;

                if (_recipeController.loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_recipeController.recipeList.isEmpty) {
                  return Center(
                    child: Text(translate("common.no_results")),
                  );
                } else {
                  recipesToShow = _recipeController.recipeList;

                  // selectedCategory means that variable has not been modified yet
                  if (_selectedCategory != null &&
                      _selectedCategory!.id != null &&
                      _selectedCategory!.id! > 0) {
                    recipesToShow = _recipeController.recipeList
                        .where((e) => e.foodCategoryId == _selectedCategory!.id)
                        .toList();
                  }

                  // selecteMeal means that variable has not been modified yet
                  if (_selectedMeal != null &&
                      _selectedMeal!.id != null &&
                      _selectedMeal!.id! > 0) {
                    recipesToShow = _filterRecipesByMeal(recipesToShow);
                  }

                  if (recipesToShow.isEmpty) {
                    return Center(
                      child: Text(translate("common.no_results")),
                    );
                  }

                  return _RecipeList(
                    recipeList: recipesToShow,
                    selectedCategory: _selectedCategory,
                  );
                }
              },
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

  List<Recipe> _filterRecipesByMeal(List<Recipe> recipesToShow) {
    List<Recipe> filteredRecipes = [];

    for (int i = 0; i < recipesToShow.length; i++) {
      final currentRecipe = recipesToShow[i];
      final selectedMeals = currentRecipe.meals
          .where((e) => e.selected)
          .where((e) => e.id == _selectedMeal!.id)
          .toList();

      if (selectedMeals.isNotEmpty) {
        filteredRecipes.add(currentRecipe);
      }
    }

    return filteredRecipes;
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
    if (widget.meals.isNotEmpty && _selectedMeal == null) {
      // No filter field
      _selectedMeal = widget.meals.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate("recipe_detail_page.meal")),
        SizedBox(height: 5),
        DropdownButtonFormField<Meal>(
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
        ),
      ],
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
    if (widget.categories.isNotEmpty && _selectedCategory == null) {
      // No filter field
      _selectedCategory = widget.categories.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate("recipe_detail_page.category")),
        SizedBox(height: 5),
        DropdownButtonFormField<FoodCategory>(
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
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            focusColor: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}

class _RecipeList extends StatelessWidget {
  final List<Recipe> recipeList;
  final FoodCategory? selectedCategory;
  final _recipeController = Get.find<RecipeController>();

  _RecipeList({
    required this.recipeList,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (_, i) => _ListItem(
        title: recipeList[i].name!,
        onDelete: () async {
          final success = await _recipeController.deleteRecipe(
            recipeList[i].id!,
          );

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
            arguments: recipeList[i],
          );
        },
      ),
      itemCount: recipeList.length,
      separatorBuilder: (_, i) => Divider(),
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
