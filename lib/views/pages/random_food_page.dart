import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/recipe_controller.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import 'recipe_detail_page.dart';

class RandomFoodPage extends StatefulWidget {
  static final routeName = "random_food";

  @override
  _RandomFoodPageState createState() => _RandomFoodPageState();
}

class _RandomFoodPageState extends State<RandomFoodPage> {
  final _recipeController = Get.find<RecipeController>();

  @override
  void initState() {
    super.initState();

    _recipeController.generateRandomRecipe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate("random_food_page.title")),
      ),
      body: GetBuilder<RecipeController>(
        builder: (_) {
          return _recipeController.loading ||
                  _recipeController.randomRecipe == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : _recipeController.randomRecipe == null &&
                      _recipeController.recipeList.isEmpty
                  ? Center(
                      child: Text(translate("common.no_results")),
                    )
                  : _recipeController.recipeList.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_recipeController.randomRecipe!.name!),
                              ElevatedButton(
                                child: Text(
                                  translate("random_food_page.recipe_details")
                                      .toUpperCase(),
                                ),
                                onPressed: () {
                                  Get.toNamed(
                                    RecipeDetailPage.routeName,
                                    arguments: _recipeController.randomRecipe,
                                  );
                                },
                              ),
                              ElevatedButton(
                                child: Text(
                                  translate("random_food_page.generate_recipe")
                                      .toUpperCase(),
                                ),
                                onPressed: () {
                                  _recipeController.generateRandomRecipe();
                                },
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(translate("common.no_results")),
                        );
        },
      ),

      /*Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedValue != null ? Text(_selectedValue!) : Container(),
              ElevatedButton(
                child: Text("Generar recepta"),
                onPressed: () {
                  int randNum = _generateRandomNumber(0, _foodList.length);

                  setState(() {
                    _selectedValue = _foodList[randNum];
                  });
                },
              ),
            ],
          ),
        ),
      ),*/
    );
  }
}
