import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/views/pages/food_categories_page.dart';
import 'package:flutter_myrecipesapp/views/pages/meals_page.dart';
import 'package:flutter_myrecipesapp/views/pages/recipe_detail_page.dart';
import 'package:flutter_myrecipesapp/views/pages/random_food_page.dart';
import 'package:flutter_myrecipesapp/views/pages/recipes_list_page.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return {
    RecipesListPage.routeName: (_) => RecipesListPage(),
    RandomFoodPage.routeName: (_) => RandomFoodPage(),
    RecipeDetailPage.routeName: (_) => RecipeDetailPage(),
    FoodCategoriesPage.routeName: (_) => FoodCategoriesPage(),
    FoodMealsPage.routeName: (_) => FoodMealsPage(),
  };
}
