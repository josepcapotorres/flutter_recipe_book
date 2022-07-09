import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/views/pages/food_categories_page.dart';
import 'package:flutter_myrecipesapp/views/pages/meals_page.dart';
import 'package:flutter_myrecipesapp/views/pages/random_food_page.dart';
import 'package:flutter_myrecipesapp/views/pages/recipes_list_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import '../../helpers/assets_helper.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Image.asset(
                    getAssetIconFilePath("launcher_icon.png"),
                  ),
                ),
                SizedBox(height: 15, width: double.infinity),
                Text(translate("common.app_name")),
              ],
            ),
          ),
          _DrawerItem(
            title: translate("recipes_list_page.title"),
            onTap: () => Get.offNamed(RecipesListPage.routeName),
          ),
          Divider(),
          _DrawerItem(
            title: translate("random_food_page.title"),
            onTap: () => Get.offNamed(RandomFoodPage.routeName),
          ),
          Divider(),
          _DrawerItem(
            title: translate("food_categories_page.title"),
            onTap: () => Get.offNamed(FoodCategoriesPage.routeName),
          ),
          Divider(),
          _DrawerItem(
            title: translate("meals_page.title"),
            onTap: () => Get.offNamed(FoodMealsPage.routeName),
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
