import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/views/pages/food_categories_page.dart';
import 'package:flutter_myrecipesapp/views/pages/meals_page.dart';
import 'package:flutter_myrecipesapp/views/pages/random_food_page.dart';
import 'package:flutter_myrecipesapp/views/pages/recipes_list_page.dart';
import 'package:get/get.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Text("Header"),
            ),
          ),
          _DrawerItem(
            title: "Llista de receptes",
            onTap: () => Get.toNamed(RecipesListPage.routeName),
          ),
          Divider(),
          _DrawerItem(
            title: "Triar recepta aleatòriament",
            onTap: () => Get.toNamed(RandomFoodPage.routeName),
          ),
          Divider(),
          _DrawerItem(
            title: "Categories de menjar",
            onTap: () => Get.toNamed(FoodCategoriesPage.routeName),
          ),
          Divider(),
          _DrawerItem(
            title: "Àpats",
            onTap: () => Get.toNamed(FoodMealsPage.routeName),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    );
  }
}
