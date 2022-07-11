import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_myrecipesapp/helpers/app_colors.dart';
import 'package:flutter_myrecipesapp/views/pages/recipes_list_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import 'controllers/food_categories_controller.dart';
import 'controllers/meals_controller.dart';
import 'controllers/recipe_controller.dart';
import 'helpers/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: ['en_US', 'es', 'ca'],
  );

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {
  // TODO: Quan TOT el desenvolupament estigui acabat, currar-se un readme.md

  @override
  Widget build(BuildContext context) {
    Get.put(MealsController());
    Get.put(FoodCategoriesController());
    Get.put(RecipeController());

    final localizationDelegate = LocalizedApp.of(context).delegate;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: translate("common.app_name"),
      initialRoute: RecipesListPage.routeName,
      routes: getApplicationRoutes(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        localizationDelegate
      ],
      supportedLocales: localizationDelegate.supportedLocales,
      locale: localizationDelegate.currentLocale,
      theme: _appThemeData,
    );
  }

  final _appThemeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      primary: AppColors.primaryColor,
      seedColor: AppColors.primaryColor,
      secondary: AppColors.primaryColorDark,
    ),
  );
}
