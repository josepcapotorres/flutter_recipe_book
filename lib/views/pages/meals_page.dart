import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/meals_controller.dart';
import 'package:flutter_myrecipesapp/models/meals.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

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
    return BasePage(
      appBar: AppBar(
        title: Text(translate("meals_page.title")),
      ),
      body: GetBuilder<MealsController>(
        builder: (_) => _mealsController.loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _mealsController.meals.isNotEmpty
                ? ListView.separated(
                    itemCount: _mealsController.meals.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, i) => _Meal(
                      _mealsController.meals[i],
                    ),
                  )
                : Center(
                    child: Text(translate("common.no_results")),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showDialog(
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

  _Meal(this.meal);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(meal.name),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => _AddMealDialog(meal: meal),
        );
      },
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          _mealsControllers.deleteMeal(meal.id!);
        },
      ),
    );
  }
}

class _AddMealDialog extends StatelessWidget {
  final _mealsController = Get.find<MealsController>();
  final _mealsEditingCtrl = TextEditingController();
  final Meal? meal;

  _AddMealDialog({this.meal}) {
    if (meal != null) {
      _mealsEditingCtrl.text = meal!.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: translate("meals_page.meal_name"),
            ),
            controller: _mealsEditingCtrl,
          ),
          ElevatedButton(
            child: Text(translate("meals_page.add_meal")),
            onPressed: () {
              if (meal != null) {
                // Call update existing meal
                meal!.name = _mealsEditingCtrl.text;
                _mealsController.updateMeal(meal!);
              } else {
                // Call insert new meal
                final meal = Meal();
                meal.name = _mealsEditingCtrl.text;

                _mealsController.newMeal(meal);
              }

              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
