import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import '../../controllers/controllers.dart';
import '../../db/db.dart';
import '../../exceptions/recipe_exceptions.dart';
import '../../helpers/date_time_helper.dart';
import '../../helpers/format_helper.dart';
import '../../models/models.dart';
import '../widgets/are_you_sure_dialog.dart';
import '../widgets/base_page.dart';
import 'recipes_list_page.dart';

// TODO: 1- Si botó mostrar calendari, seleccionar dia que estigui recepta a calendari amb última data SI està al calendari i si està dins aquesta o la següent setmana. PROVAT I FUNCIONA
// TODO: Si no hi és al calendari, seleccionar dia actual. FUNCIONA
// TODO: Si guardam recepta i ja tenia guardat calendari dins aquesta o setmana que ve, modificar aquesta línia a calendari per data nova. ARA INSEREIX EL PLAT COM UN DIA MÉS. PER TANT, HI HAURÀ DOS REGISTRES EN DUES DATES DIFERENTS

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
  final _ingredientsCtrl = Get.find<IngredientController>();
  final _calendarCtrl = Get.find<CalendarController>();
  final _recipeIngredientsCtrl = Get.find<RecipeIngredientController>();
  final _recipeNameCtrl = TextEditingController();
  final _nPersonsCtrl = TextEditingController();
  final _stepsCookingCtrl = TextEditingController();
  DateTime? _selectedCalendarDate;
  Meal? _selectedCalendarMeal;
  bool _methodsExecuted = false;

  @override
  Widget build(BuildContext context) {
    final selectedRecipe =
        ModalRoute.of(context)!.settings.arguments as Recipe?;
    FoodCategory? selectedCategory;
    String titlePage;

    if (selectedRecipe != null) {
      _recipeNameCtrl.text = selectedRecipe.name!;
      _nPersonsCtrl.text = selectedRecipe.nPersons.toString();
      _stepsCookingCtrl.text = selectedRecipe.stepsReproduce;
      selectedCategory = FoodCategory();
      selectedCategory
        ..id = selectedRecipe.foodCategoryId
        ..name = selectedRecipe.name!
        ..selected = true;
      titlePage = selectedRecipe.name!;

      if (!_methodsExecuted) {
        Future.microtask(() {
          _mealsController.fetchMeals(recipeId: selectedRecipe.id!);
          _foodCategoryCtrl.fetchFoodCategories(recipeId: selectedRecipe.id!);
          _ingredientsCtrl.getIngredientsByRecipeId(selectedRecipe.id!);
          _recipeIngredientsCtrl
              .getRecipeIngredientsByRecipeId(selectedRecipe.id!);
        });

        _methodsExecuted = true;
      }
    } else {
      titlePage = translate("recipe_detail_page.title");

      if (!_methodsExecuted) {
        Future.microtask(() {
          _mealsController.fetchMeals();
          _foodCategoryCtrl.fetchFoodCategories();
          _ingredientsCtrl.getIngredients();
        });

        _methodsExecuted = true;
      }
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
                        return CircularProgressIndicator.adaptive();
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
                    message: translate("validations.empty_meals_field"),
                  );
                  return;
                }

                if (selectedCategory == null ||
                    selectedCategory!.selected == false) {
                  Get.rawSnackbar(
                    message: translate("validations.empty_category_field"),
                  );

                  return;
                }

                if (_recipeIngredientsCtrl.recipeIngredients.isEmpty) {
                  Get.rawSnackbar(
                    message: translate(
                      "recipe_detail_page.no_ingredient_selected",
                    ),
                  );

                  return;
                }

                Get.dialog(
                  AreYouSureDialog(
                    onYes: () async {
                      int recipeId;

                      try {
                        Get.back();

                        if (selectedRecipe == null) {
                          /*final newRecipe = await _saveRecipe(
                            selectedRecipe,
                            selectedCategory,
                          );

                          recipeId = newRecipe.id!;*/

                          Get.rawSnackbar(
                            message: translate(
                              "recipe_detail_page.recipe_created_successfuly",
                            ),
                          );
                        } else {
                          recipeId = selectedRecipe.id!;

                          final updatedRecipe = Recipe(
                            id: recipeId,
                            name: selectedRecipe.name,
                            nPersons: selectedRecipe.nPersons,
                            stepsReproduce: selectedRecipe.stepsReproduce,
                            foodCategoryId: selectedRecipe.foodCategoryId,
                            meals: selectedRecipe.meals,
                          );

                          /*await _updateCalendarCell(
                            selectedMeal: _selectedCalendarMeal!,
                            selectedRecipe: updatedRecipe,
                          );*/

                          Get.rawSnackbar(
                            message: translate(
                              "recipe_detail_page.recipe_updated_successfuly",
                            ),
                          );
                        }

                        if (_selectedCalendarDate != null &&
                            _selectedCalendarMeal != null) {
                          /*final dateIfRecipeInCalendar = await _calendarCtrl
                              .getDateIfRecipeInCalendarBetweenDates(
                            recipeId: recipeId,
                          );*/

                          /*
                          POSSIBLES ESTATS:
                          1) Venc per primera vegada a guardar una recepta.
                          2) Recepta ja guardada i encara no està dins es calendari
                          3) Recepta ja guardada i ja està dins es calendari
                          ACTUALITZACIÓ de punt 3:
                          3) Recepta ja guardada i ja està dins es calendari, però és pel mateix dia
                          4) Recepta ja guardada i ja està dins es calendari, però és per altre dias
                          */

                          /*if (dateIfRecipeInCalendar != null &&
                              selectedRecipe != null) {
                            // If it's the same datetime it means that the
                            // modified field might be the meal
                            if (dateIfRecipeInCalendar ==
                                _selectedCalendarDate) {
                              await _updateCalendarCell(
                                selectedMeal: _selectedCalendarMeal!,
                                selectedRecipe: selectedRecipe,
                              );
                            }
                          } else if (dateIfRecipeInCalendar == null) {
                            final recipeMap = <String, dynamic>{
                              "id": recipeId,
                              "name": _recipeNameCtrl.text.trim(),
                              "n_persons": _nPersonsCtrl.text.trim(),
                              "steps_reproduce": _stepsCookingCtrl.text.trim(),
                              "food_category_id": selectedCategory?.id,
                              "meals": _mealsController.selectedMeals
                                  .map((e) => e.toJson())
                                  .toList(),
                            };

                            final recipeData = Recipe.fromJson(recipeMap);

                            await _storeCalendarCell(
                              selectedMeal: _selectedCalendarMeal!,
                              selectedRecipe: recipeData,
                            );
                          }*/
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
              _IngredientsList(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_ingredientsCtrl.ingredients.isEmpty) {
                      showAdaptiveDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            content: Text(
                              translate(
                                "recipe_detail_page.no_ingredients_registered",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(translate("common.cancel")),
                              ),
                            ],
                          );
                        },
                      );

                      return;
                    }

                    final result = await showAdaptiveDialog<RecipeIngredient?>(
                      context: context,
                      builder: (_) {
                        return _IngsQuantsDialog(
                          selectedRecipe: selectedRecipe,
                        );
                      },
                    );

                    // If ingredient is selected and form validated before
                    // popup has dismissed
                    if (result != null) {
                      _recipeIngredientsCtrl.recipeIngredients.add(result);
                    }

                    _recipeIngredientsCtrl.refreshScreen();
                  },
                  child: Text(
                    translate(
                      "recipe_detail_page.add_ings_and_quants",
                    ).toUpperCase(),
                  ),
                ),
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
          // Loop collection and set recipe id
          _recipeIngredientsCtrl.fillRecipeId(recipe.id!);

          final resultIngredients =
              await _recipeIngredientsCtrl.newRecipeIngredients();

          if (!resultIngredients) {
            throw SaveRecipeIngredientException(
              translate("recipe_detail_page.err_insert_recipe_ings"),
            );
          }

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
      recipe.id = arguments!.id;
      final recipeTable = Get.find<RecipeTable>();

      final updatedId = await recipeTable.updateRecipe(
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

      // TODO: Petició sql update a recipe_ingredient

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

  // TODO: Refactor a controller
  Future<void> _updateCalendarCell({
    required Meal selectedMeal,
    required Recipe selectedRecipe,
  }) async {
    final calendarTable = Get.find<CalendarTable>();
    final calendarData = await calendarTable.getCalendarData();

    final selectedCalendarCell = calendarData
        .where((e) =>
            e.recipeId == selectedRecipe.id! &&
            e.date == _selectedCalendarDate!)
        .toList();

    if (selectedCalendarCell.isNotEmpty) {
      final calendarCellData = FilledCalendarCell(
        id: selectedCalendarCell.first.id!,
        recipeId: selectedRecipe.id,
        mealId: selectedMeal.id,
        recipeName: selectedRecipe.name!,
        date: _selectedCalendarDate!,
      );

      await _calendarCtrl.updateRecipeInCalendar(calendarCellData);
    }
  }
}

class _IngredientsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecipeIngredientController>(
      builder: (ingsCtrl) {
        if (ingsCtrl.loading) {
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate("recipe_detail_page.ings_and_quants")),
            ingsCtrl.recipeIngredients.isEmpty
                ? SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        translate("common.no_results"),
                      ),
                    ),
                  )
                : ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (_, i) => ListTile(
                      title: Text(
                        _getIngredientLine(ingsCtrl.recipeIngredients[i]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          ingsCtrl.removeIngredient(i);
                        },
                      ),
                    ),
                    separatorBuilder: (_, __) => Divider(),
                    itemCount: ingsCtrl.recipeIngredients.length,
                  ),
            /*[
                  Text("100g de sucre"),
                  Divider(),
                  Text("2 cullerades de mel"),
                ],
                    ),*/
          ],
        );
      },
    );
  }

  String _getIngredientLine(RecipeIngredient recipeIngredient) {
    final quantityIngredient = removeDecimalIfPossible(
      recipeIngredient.quantityIngredient,
    );
    final unit = recipeIngredient.unit.toLowerCase();
    final ofLabel = translate("common.of");
    final ingredientName = recipeIngredient.ingredientName?.toLowerCase();

    return "$quantityIngredient $unit $ofLabel $ingredientName";
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
            (e) => CheckboxListTile.adaptive(
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

class _IngredientItem extends StatelessWidget {
  final VoidCallback onDelete;
  final Ingredient ingredient;

  const _IngredientItem(this.ingredient, {required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(color: Color(0xFFDDDDDD)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(ingredient.name ?? "-"),
          SizedBox(width: 5),
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: onDelete,
            icon: Icon(Icons.clear),
          ),
        ],
      ),
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
        return RadioListTile.adaptive(
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

class _IngsQuantsDialog extends StatefulWidget {
  final Recipe? selectedRecipe;

  _IngsQuantsDialog({required this.selectedRecipe});

  @override
  State<_IngsQuantsDialog> createState() => _IngsQuantsDialogState();
}

// TODO: Si recepta existent i data calendari guardat d'antelació, modifiques data i no fa res. Es queda com està

class _IngsQuantsDialogState extends State<_IngsQuantsDialog> {
  Ingredient? _selectedIng;
  final _ingQuantityCtrl = TextEditingController();
  final _ingUnitCtrl = TextEditingController();
  final _ingNameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _ingredientsCtrl = Get.find<IngredientController>();

  @override
  void initState() {
    super.initState();

    _ingredientsCtrl.getIngredients();
    _selectedIng = null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _ingQuantityCtrl,
                    decoration: InputDecoration(
                      labelText: translate("recipe_detail_page.quantity"),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: false),
                    validator: (val) {
                      final fstValidation = validateEmptyField(val);

                      if (fstValidation != null) {
                        return fstValidation;
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ingUnitCtrl,
                    decoration: InputDecoration(
                      labelText: translate("recipe_detail_page.unit"),
                    ),
                    validator: validateEmptyField,
                  ),
                  TextFormField(
                    controller: _ingNameCtrl,
                    decoration: InputDecoration(
                      labelText: translate(
                        "ingredients_page.filter_by_ing_name",
                      ),
                    ),
                    onChanged: (val) {
                      print("onChanged. ing name search: ${_ingNameCtrl.text}");

                      _selectedIng = null;

                      _ingredientsCtrl.getIngredientsByName(
                        recipeId: widget.selectedRecipe?.id,
                        ingName: _ingNameCtrl.text,
                      );
                    },
                  ),
                  SizedBox(height: 5),
                  GetBuilder<IngredientController>(
                    builder: (_) {
                      if (_.loading) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }

                      if (_selectedIng == null) {
                        _selectedIng = _.ingredients.firstOrNull;
                      }

                      if (_selectedIng == null) {
                        return Text(translate("common.no_results"));
                      }

                      return DropdownButton<Ingredient>(
                        value: _selectedIng!,
                        items: _.ingredients.map(
                          (e) {
                            return DropdownMenuItem(
                              child: Text(e.name ?? "-"),
                              value: e,
                            );
                          },
                        ).toList(),
                        isExpanded: true,
                        onChanged: (val) {
                          setState(() {
                            _selectedIng = val;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _validateForm(
              _formKey,
              double.parse(_ingQuantityCtrl.text.trim()),
              _ingUnitCtrl.text.trim(),
            );
          },
          child: Text(translate(
            "ingredients_page.save_ingredient",
          ).toUpperCase()),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(translate("common.cancel").toUpperCase()),
        ),
      ],
    );
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

  void _validateForm(
      GlobalKey<FormState> formKey, double quantity, String unit) {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      final recipeIngredientData = <String, dynamic>{
        "idIngredient": _selectedIng!.id!,
        "unit": unit,
        "quantityIngredient": quantity,
        "ingredient_name": _selectedIng!.name!,
      };

      Navigator.pop(
        context,
        RecipeIngredient.fromJson(recipeIngredientData),
      );
    }
  }
}
