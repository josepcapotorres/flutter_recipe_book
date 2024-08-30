import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_myrecipesapp/views/pages/recipes_list_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import 'controllers/controllers.dart';
import 'db/db.dart';
import 'firebase_options.dart';
import 'helpers/app_colors.dart';
import 'helpers/routes.dart';

// TODO: Després del canvi amb els ingredients, QUE JA FUNCIONA, arreglar afegir recepta a calendari. La part dels ingredients ha canviat.
// TODO: Provar d'actualitzar algún camp d'una recepta existent i comprovar que es reflexi al calendari

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  var delegate = await LocalizationDelegate.create(
    fallbackLocale: 'en_US',
    supportedLocales: ['en_US', 'es', 'ca'],
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(LocalizedApp(delegate, MyApp()));

  //await DBController.instance.deleteOldCalendarEntries();
}

class MyApp extends StatelessWidget {
  // TODO: Quan TOT el desenvolupament estigui acabat, currar-se un readme.md
  // TODO: Implementar crashlytics
  // TODO: Traduir TOTS els texts. Provat TOT en cada idioma
  // TODO: Provar amb dispositiu amb pantalla petita
  // TODO: En cada error produït, crear una excepció pel cas que surti per mostrar-lo per pantalla
  // TODO: Comprovar que a totes ses taules de sa bd, es camp autonumèric no queda null al insertar una fila

  @override
  Widget build(BuildContext context) {
    // Database manager
    Get.put(RecipeTable());
    Get.put(MealTable());
    Get.put(FoodCategoryTable());
    Get.put(RecipeMealTable());
    Get.put(CalendarTable());
    Get.put(IngredientTable());
    Get.put(RecipeIngredientTable());

    // Controllers
    Get.put(MealsController());
    Get.put(FoodCategoriesController());
    Get.put(RecipeController());
    Get.put(CalendarController());
    Get.put(IngredientController());
    Get.put(RecipeIngredientController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: translate("common.app_name"),
      initialRoute: RecipesListPage.routeName,
      routes: getApplicationRoutes(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: _appThemeData,
    );
  }

  final _appThemeData = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      primary: AppColors.primaryColor,
      seedColor: AppColors.primaryColor,
      secondary: AppColors.primaryColorDark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryColor,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.primaryColorDark),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((_) => Colors.black),
        textStyle: WidgetStateProperty.resolveWith(
          (_) => TextStyle(fontSize: 16),
        ),
      ),
    ),
  );
}
