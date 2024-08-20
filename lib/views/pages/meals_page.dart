import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/db/db.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import '../widgets/are_you_sure_dialog.dart';

class FoodMealsPage extends StatefulWidget {
  static const String routeName = "meals";

  @override
  _FoodMealsPageState createState() => _FoodMealsPageState();
}

class _FoodMealsPageState extends State<FoodMealsPage> {
  final _mealsController = Get.find<MealsController>();

  @override
  void initState() {
    super.initState();

    _mealsController.fetchMeals();
  }

  @override
  Widget build(BuildContext context) {
    try {
      Get.find<MealTable>().getMeals().then((meals) {
        meals.forEach((e) {
          print("meal: ${e.toJson()}");
        });
      });
    } catch (e) {
      print("");
    }

    return BasePage(
      appBar: AppBar(
        title: Text(translate("meals_page.title")),
      ),
      body: GetBuilder<MealsController>(
        builder: (_) => _mealsController.loading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : _mealsController.meals.isNotEmpty
                ? ReorderableListView.builder(
                    itemCount: _mealsController.meals.length,
                    itemBuilder: (_, i) => _Meal(
                      _mealsController.meals[i],
                      key: Key("$i"),
                    ),
                    onReorder: (oldIndex, newIndex) async {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }

                      await _mealsController.changeMealOrder(
                        oldMeal: _mealsController.meals[oldIndex],
                        newMeal: _mealsController.meals[newIndex],
                      );

                      _mealsController.fetchMeals();
                    },
                  )
                : Center(
                    child: Text(translate("common.no_results")),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showAdaptiveDialog(
          context: context,
          builder: (_) => _AddMealDialog(),
        ),
      ),
    );
  }
}

class _Meal extends StatelessWidget {
  final _mealsControllers = Get.find<MealsController>();
  final Meal meal;
  final Key key;

  _Meal(this.meal, {required this.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: key,
      title: Text(meal.name),
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: (_) => _AddMealDialog(meal: meal),
        );
      },
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (meal.id! == 0) {
            Get.rawSnackbar(
              message: translate("meals_page.cannot_del_meal"),
            );

            return;
          }

          Get.dialog(
            AreYouSureDialog(
              onYes: () {
                _mealsControllers.deleteMeal(meal.id!);
                Get.back();
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddMealDialog extends StatelessWidget {
  final _mealsController = Get.find<MealsController>();
  final _mealsEditingCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Meal? meal;

  _AddMealDialog({this.meal}) {
    if (meal != null) {
      _mealsEditingCtrl.text = meal!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: translate("meals_page.meal_name"),
              ),
              controller: _mealsEditingCtrl,
              validator: _mealsController.validateEmptyField,
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: _ButtonText(meal),
          onPressed: () {
            if (meal != null && meal!.id! == 0) {
              Get.rawSnackbar(
                message: translate(
                  "meals_page.cannot_modify_meal",
                ),
              );

              return;
            }

            final formState = _formKey.currentState;

            if (formState?.validate() ?? false) {
              formState?.save();

              if (meal != null) {
                // Call update existing meal
                meal!.name = _mealsEditingCtrl.text.trim();
                _mealsController.updateMeal(meal!);
              } else {
                // Call insert new meal
                final meal = Meal();
                meal.name = _mealsEditingCtrl.text;

                _mealsController.newMeal(meal);
              }

              Get.back();
            }
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(translate("common.cancel").toUpperCase()),
        ),
      ],
    );
  }
}

class _ButtonText extends StatelessWidget {
  final Meal? meal;

  const _ButtonText(this.meal);

  @override
  Widget build(BuildContext context) {
    String buttonText;

    if (meal == null) {
      buttonText = translate("meals_page.add_meal");
    } else {
      buttonText = translate("meals_page.modify_meal");
    }

    return Text(buttonText.toUpperCase());
  }
}
