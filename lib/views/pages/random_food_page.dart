import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/recipe_controller.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import 'recipe_detail_page.dart';

class RandomFoodPage extends StatefulWidget {
  static final routeName = "random_food";

  @override
  State<RandomFoodPage> createState() => _RandomFoodPageState();
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
    return BasePage(
      appBar: AppBar(
        title: Text(translate("random_food_page.title")),
      ),
      body: GetBuilder<RecipeController>(
        id: "random_food",
        builder: (_) {
          if (_recipeController.loading) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (_recipeController.recipeList.isNotEmpty) {
            return Center(
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
            );
          } else {
            return Center(
                child: Text(
                    "No tens receptes guardades encara. Crea'n diverses per poder utilitzar aquesta característica")
                //Text(translate("common.no_results")),
                );
          }
        },
      ),
    );
  }
}
