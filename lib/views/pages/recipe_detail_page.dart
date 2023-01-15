import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/calendar_controller.dart';
import 'package:flutter_myrecipesapp/controllers/database_controller.dart';
import 'package:flutter_myrecipesapp/controllers/food_categories_controller.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/controllers/recipe_controller.dart';
import 'package:flutter_myrecipesapp/helpers/date_time_helper.dart';
import 'package:flutter_myrecipesapp/models/calendar_cell.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/models/recipe.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import '../../exceptions/recipe_exceptions.dart';
import '../../helpers/format_helper.dart';
import '../widgets/are_you_sure_dialog.dart';
import 'recipes_list_page.dart';

class RecipeDetailPage extends StatefulWidget {
  static final routeName = "recipe_detail";

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _mealsController = Get.find<MealsController>();
  final _foodCategoryCtrl = Get.find<FoodCategoriesController>();
  final _recipeController = Get.find<RecipeController>();
  final _calendarCtrl = Get.find<CalendarController>();
  final _recipeNameCtrl = TextEditingController();
  final _nPersonsCtrl = TextEditingController();
  final _ingsQuantsCtrl = TextEditingController();
  final _stepsCookingCtrl = TextEditingController();
  DateTime? _selectedCalendarDate;
  Meal? _selectedCalendarMeal;

  @override
  Widget build(BuildContext context) {
    final selectedRecipe =
        ModalRoute.of(context)!.settings.arguments as Recipe?;
    FoodCategory? selectedCategory;
    String titlePage;

    if (selectedRecipe != null) {
      _recipeNameCtrl.text = selectedRecipe.name!;
      _nPersonsCtrl.text = selectedRecipe.nPersons.toString();
      _ingsQuantsCtrl.text = selectedRecipe.ingsAndQuants;
      _stepsCookingCtrl.text = selectedRecipe.stepsReproduce;
      selectedCategory = FoodCategory();
      selectedCategory
        ..id = selectedRecipe.foodCategoryId
        ..name = selectedRecipe.name!
        ..selected = true;
      titlePage = selectedRecipe.name!;

      _mealsController.fetchMeals(recipeId: selectedRecipe.id!);
      _foodCategoryCtrl.fetchFoodCategories(recipeId: selectedRecipe.id!);
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
            icon: Icon(Icons.calendar_month, size: 32),
            onPressed: () async {
              _selectedCalendarDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: getLastDayOfNextWeek(),
              );

              if (_selectedCalendarDate == null) return;

              Get.dialog(
                AlertDialog(
                  content: GetBuilder<MealsController>(
                    builder: (_) {
                      if (_.loading) {
                        return CircularProgressIndicator();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: _.meals
                            .map((e) => ListTile(
                                  title: Text(e.name),
                                  onTap: () {
                                    _selectedCalendarMeal = e;
                                    Get.back();
                                  },
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.save, size: 32),
            onPressed: () {
              final formState = _formKey.currentState;

              if (formState?.validate() ?? false) {
                formState?.save();

                if (!_mealsController.isMealFieldValidated()) {
                  Get.rawSnackbar(
                      message: translate("validations.empty_meals_field"));
                  return;
                }

                if (selectedCategory == null ||
                    selectedCategory!.selected == false) {
                  Get.rawSnackbar(
                      message: translate("validations.empty_category_field"));

                  return;
                }

                Get.dialog(
                  AreYouSureDialog(
                    onYes: () async {
                      try {
                        final newRecipe = await _saveRecipe(
                          selectedRecipe,
                          selectedCategory,
                        );

                        Get.back();

                        if (selectedRecipe == null) {
                          Get.rawSnackbar(
                            message: translate(
                              "recipe_detail_page.recipe_created_successfuly",
                            ),
                          );
                        } else {
                          Get.rawSnackbar(
                            message: translate(
                              "recipe_detail_page.recipe_updated_successfuly",
                            ),
                          );
                        }

                        if (_selectedCalendarDate != null &&
                            _selectedCalendarMeal != null) {
                          await _storeCalendarCell(
                            selectedMeal: _selectedCalendarMeal!,
                            selectedRecipe: newRecipe,
                          );
                        }
                      } on RelationRecipeMealException catch (e) {
                        Get.rawSnackbar(message: e.message);
                      } on SaveNewRecipeException catch (e) {
                        Get.rawSnackbar(message: e.message);
                      } on DeleteRecipeException catch (e) {
                        Get.rawSnackbar(message: e.message);
                      } on UpdateRecipeDataException catch (e) {
                        Get.rawSnackbar(message: e.message);
                      }

                      Get.offNamedUntil(
                        RecipesListPage.routeName,
                        (route) => false,
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _recipeNameCtrl,
                decoration: InputDecoration(
                  labelText: translate("recipe_detail_page.recipe_name"),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: _recipeController.validateEmptyField,
              ),
              TextFormField(
                controller: _nPersonsCtrl,
                decoration: InputDecoration(
                  labelText: translate("recipe_detail_page.n_people"),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: false),
                validator: (_) {
                  final emptyValidation = _recipeController.validateEmptyField(
                    _nPersonsCtrl.text,
                  );

                  if (emptyValidation != null) {
                    return emptyValidation;
                  }

                  if (!isNumeric(_nPersonsCtrl.text)) {
                    return translate("validations.value_must_be_number");
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(height: 15),
              Text(translate("recipe_detail_page.meal")),
              GetBuilder<MealsController>(
                builder: (_) {
                  return _MealDropdownList(
                    _mealsController.meals.skip(0).toList(),
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
              TextFormField(
                controller: _ingsQuantsCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: translate("recipe_detail_page.ings_and_quants"),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: _recipeController.validateEmptyField,
              ),
              TextFormField(
                controller: _stepsCookingCtrl,
                maxLines: 7,
                decoration: InputDecoration(
                  labelText: translate("recipe_detail_page.steps_follow"),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: _recipeController.validateEmptyField,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Recipe> _saveRecipe(
      Recipe? arguments, FoodCategory? selectedCategory) async {
    final recipeMap = <String, dynamic>{
      "name": _recipeNameCtrl.text.trim(),
      "n_persons": _nPersonsCtrl.text.trim(),
      "ings_and_quants": _ingsQuantsCtrl.text.trim(),
      "steps_reproduce": _stepsCookingCtrl.text.trim(),
      "food_category_id": selectedCategory?.id,
      "meals": _mealsController.selectedMeals.map((e) => e.toJson()).toList(),
    };

    final recipe = Recipe.fromJson(recipeMap);

    // It checks if the recipe doesn't exist
    if (arguments?.id == null) {
      final insertedId = await _recipeController.newRecipe(
        Recipe.fromJson(recipeMap),
      );

      // It checks if db query successes
      if (insertedId > 0) {
        recipe.id = insertedId;

        final selectedMeals =
            _mealsController.selectedMeals.where((e) => e.selected).toList();
        final insertResult =
            await _mealsController.insertRecipeMeals(insertedId, selectedMeals);

        if (insertResult) {
          Get.back(); // It removes the AreYouSure popup widget

          return recipe;
        } else {
          throw RelationRecipeMealException(
            translate("recipe_detail_page.error_relation_recipe_meal"),
          );
        }
      } else {
        throw SaveNewRecipeException(
          translate("recipe_detail_page.error_saving_new_recipe"),
        );
      }
    } else {
      //recipeMap["id"] = arguments!.id;
      recipe.id = arguments!.id;

      final updatedId = await DBController.instance.updateRecipe(
        recipe,
      );

      // If mode = editing existing recipe, we delete
      final deleteResult = await _mealsController.deleteMealsByRecipeId(
        recipe.id!,
      );

      if (!deleteResult) {
        throw DeleteRecipeException(
          translate("recipe_detail_page.error_deleting_recipe"),
        );
      }

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
          return recipe;
        } else {
          throw RelationRecipeMealException(
            translate("recipe_detail_page.error_relation_recipe_meal"),
          );
        }
      } else {
        throw UpdateRecipeDataException(
          translate("recipe_detail_page.error_update_recipe_data"),
        );
      }
    }
  }

  Future<void> _storeCalendarCell({
    required Meal selectedMeal,
    required Recipe selectedRecipe,
  }) async {
    final calendarData = FilledCalendarCell(
      recipeId: selectedRecipe.id,
      mealId: selectedMeal.id,
      recipeName: selectedRecipe.name!,
      date: _selectedCalendarDate!,
    );

    await _calendarCtrl.insertRecipeInCalendar(calendarData);
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
    // It returns a meal without the one that has id = 0.
    // A meal with id = 0 means refers to the "Sin especificar" entry
    final meals = widget.meals.where((e) {
      return e.id?.compareTo(0) != 0;
    }).toList();

    return Column(
      children: meals
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
    // It returns a category without the one that has id = 0.
    // A category with id = 0 means refers to the "Sin especificar" entry
    final categories = widget.categories.where((e) {
      return e.id?.compareTo(0) != 0;
    }).toList();

    return Column(
      children: categories.map((e) {
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
