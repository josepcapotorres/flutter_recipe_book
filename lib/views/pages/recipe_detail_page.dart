import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/database_controller.dart';
import 'package:flutter_myrecipesapp/controllers/food_categories_controller.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/controllers/recipe_controller.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class RecipeDetailPage extends StatelessWidget {
  static final routeName = "recipe_detail";

  final _mealsController = Get.find<MealsController>();
  final _foodCategoryCtrl = Get.find<FoodCategoriesController>();
  final _recipeController = Get.find<RecipeController>();
  final _recipeNameCtrl = TextEditingController(text: "Espaguetis");
  final _nPersonsCtrl = TextEditingController(text: "2");
  final _ingsQuantsCtrl = TextEditingController(text: "I");
  final _stepsCookingCtrl = TextEditingController(text: "P");

  @override
  Widget build(BuildContext context) {
    /// TODO: Falta validar els camps de text

    final arguments = ModalRoute.of(context)!.settings.arguments as Recipe?;
    FoodCategory? selectedCategory;
    String titlePage;

    if (arguments != null) {
      _recipeNameCtrl.text = arguments.name!;
      _nPersonsCtrl.text = arguments.nPersons.toString();
      _ingsQuantsCtrl.text = arguments.ingsAndQuants;
      _stepsCookingCtrl.text = arguments.stepsReproduce;
      selectedCategory = FoodCategory();
      selectedCategory
        ..id = arguments.foodCategoryId
        ..name = arguments.name!
        ..selected = true;
      titlePage = arguments.name!;

      _mealsController.fetchMeals(recipeId: arguments.id!);
      _foodCategoryCtrl.fetchFoodCategories(recipeId: arguments.id!);
    } else {
      titlePage = translate("recipe_detail_page.title");
      _mealsController.fetchMeals();
      _foodCategoryCtrl.fetchFoodCategories();
    }

    return BasePage(
      appBar: AppBar(
        title: Text(titlePage),
        actions: [
          IconButton(
            icon: Icon(Icons.save, size: 32),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(translate("recipe_detail_page.are_you_sure")),
                  actions: [
                    TextButton(
                      child: Text(translate("common.yes").toUpperCase()),
                      onPressed: () {
                        Get.back();
                        _saveRecipe(arguments, selectedCategory);
                      },
                    ),
                    TextButton(
                      child: Text(translate("common.no").toUpperCase()),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          TextField(
            controller: _recipeNameCtrl,
            decoration: InputDecoration(
              labelText: translate("recipe_detail_page.recipe_name"),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          TextField(
            controller: _nPersonsCtrl,
            decoration: InputDecoration(
              labelText: translate("recipe_detail_page.n_people"),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 15),
          Text(translate("recipe_detail_page.meal")),
          GetBuilder<MealsController>(
            builder: (_) {
              return _MealDropdownList(
                _mealsController.meals,
                onChanged: (List<Meal> meals) {
                  _mealsController.selectedMeals = meals;
                },
              );
            },
          ),
          Text(translate("recipe_detail_page.category")),
          GetBuilder<FoodCategoriesController>(
            builder: (_) {
              for (final category in _foodCategoryCtrl.categories) {
                if (category.selected) {
                  selectedCategory = category;
                }
              }

              return _FoodTypeList(
                _foodCategoryCtrl.categories,
                selectedCategory: selectedCategory,
                onChanged: (category) {
                  selectedCategory = category;
                  selectedCategory!.selected = true;
                },
              );
            },
          ),
          TextField(
            controller: _ingsQuantsCtrl,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: translate("recipe_detail_page.ings_and_quants"),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          TextField(
            controller: _stepsCookingCtrl,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: translate("recipe_detail_page.steps_follow"),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  void _saveRecipe(Recipe? arguments, FoodCategory? selectedCategory) async {
    final recipeMap = <String, dynamic>{
      "name": _recipeNameCtrl.text,
      "n_persons": _nPersonsCtrl.text,
      "ings_and_quants": _ingsQuantsCtrl.text,
      "steps_reproduce": _stepsCookingCtrl.text,
      "food_category_id": selectedCategory?.id,
      "meals": _mealsController.selectedMeals.map((e) => e.toJson()).toList(),
    };

    /*if (arguments != null) {
      recipeMap["id"] = arguments.id;
    }*/

    final recipe = Recipe.fromJson(recipeMap);

    // It checks if the recipe doesn't exist
    if (arguments?.id == null) {
      final insertedId =
          await _recipeController.newRecipe(Recipe.fromJson(recipeMap));

      // It checks if db query successes
      if (insertedId > 0) {
        final selectedMeals =
            _mealsController.selectedMeals.where((e) => e.selected).toList();
        final insertResult =
            await _mealsController.insertRecipeMeals(insertedId, selectedMeals);

        if (insertResult) {
          Get.back();
          _recipeController.fetchRecipeList();
          Get.rawSnackbar(
            message: translate("recipe_detail_page.recipe_created_successfuly"),
          );
        } else {
          Get.rawSnackbar(
            message: translate("recipe_detail_page.error_relation_recipe_meal"),
          );
        }
      } else {
        Get.rawSnackbar(
          message: translate("recipe_detail_page.error_saving_new_recipe"),
        );
      }
    } else {
      //recipeMap["id"] = arguments!.id;
      recipe.id = arguments!.id;

      final updatedId = await DBController.instance.updateRecipe(
        recipe,
      );

      // If mode = editing existing recipe, we delete
      final deleteResult =
          await _mealsController.deleteMealsByRecipeId(recipe.id!);

      // TODO: if error, show error message
      if (deleteResult) {
        // Ensure to insert the SELECTED meals on the screen
        final selectedMeals =
            _mealsController.selectedMeals.where((e) => e.selected).toList();

        final recipeMealsResult = await _mealsController.insertRecipeMeals(
          recipe.id!,
          selectedMeals,
        );

        Get.back();
        Get.back();

        // It checks if update query is success
        if (updatedId) {
          if (recipeMealsResult) {
            Get.rawSnackbar(
              message: translate(
                "recipe_detail_page.recipe_updated_successfuly",
              ),
            );
          } else {
            Get.rawSnackbar(
              message: translate(
                "recipe_detail_page.error_relation_recipe_meal",
              ),
            );
          }
        } else {
          Get.rawSnackbar(
            message: translate(
              "recipe_detail_page.error_update_recipe_data",
            ),
          );
        }
      }
    }
  }
}

class _MealDropdownList extends StatefulWidget {
  final List<Meal> meals;
  final Function(List<Meal>) onChanged;

  _MealDropdownList(this.meals, {required this.onChanged});

  @override
  _MealDropdownListState createState() => _MealDropdownListState();
}

class _MealDropdownListState extends State<_MealDropdownList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.meals
          .map(
            (e) => CheckboxListTile(
              value: e.selected,
              title: Text(e.name),
              onChanged: (value) {
                setState(() {
                  final selectedItem =
                      widget.meals.where((element) => element == e).first;
                  selectedItem.selected = value!;

                  widget.onChanged(widget.meals);
                });
              },
              activeColor: Colors.green,
            ),
          )
          .toList(),
    );
  }
}

class _FoodTypeList extends StatefulWidget {
  final List<FoodCategory> categories;
  final Function(FoodCategory) onChanged;
  FoodCategory? selectedCategory;

  _FoodTypeList(
    this.categories, {
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  _FoodTypeListState createState() => _FoodTypeListState();
}

class _FoodTypeListState extends State<_FoodTypeList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.categories.map((e) {
        /*if (e.id == widget.selectedCategory!.id) {
          e.selected = true;
        }*/

        return RadioListTile<FoodCategory>(
          value: e,
          groupValue: widget.selectedCategory,
          title: Text(e.name),
          onChanged: (value) {
            setState(() {
              widget.selectedCategory = value;
              widget.onChanged(widget.selectedCategory!);
            });
          },
          activeColor: Colors.green,
        );
      }).toList(),
    );
  }
}
