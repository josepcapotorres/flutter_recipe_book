import 'package:flutter_myrecipesapp/db/db.dart';
import 'package:flutter_myrecipesapp/db/tables/meal_table.dart';
import 'package:flutter_myrecipesapp/enums/calendar_week_displayed.dart';
import 'package:flutter_myrecipesapp/models/calendar_cell.dart';
import 'package:get/get.dart';

import '../helpers/date_time_helper.dart';

class CalendarController extends GetxController {
  late CalendarTable _calendarManager;

  CalendarWeekDisplayed weekDisplayed = CalendarWeekDisplayed.currentWeek;

  bool get isDisplayingCurrWeek =>
      weekDisplayed == CalendarWeekDisplayed.currentWeek;
  bool get isDisplayingNextWeek =>
      weekDisplayed == CalendarWeekDisplayed.nextWeek;

  List<List<CalendarCell>> get _currWeekCalFoodData {
    return calendarFoodData.take(7).toList();
  }

  List<List<CalendarCell>> get _nextWeekCalFoodData {
    return calendarFoodData.getRange(7, 14).toList();
  }

  List<List<CalendarCell>> get calendarWeekData {
    switch (weekDisplayed) {
      case CalendarWeekDisplayed.currentWeek:
        return _currWeekCalFoodData;
      case CalendarWeekDisplayed.nextWeek:
        return _nextWeekCalFoodData;
    }
  }

  List<List<CalendarCell>> calendarFoodData = [];

  @override
  void onInit() {
    super.onInit();

    _calendarManager = Get.find<CalendarTable>();
  }

  void getCalendarData() async {
    final mealManager = Get.find<MealTable>();
    List<CalendarCell> weekCells;
    List<FilledCalendarCell> calendarCellsInDb =
        await _calendarManager.getCalendarData();

    final meals = await mealManager.getMeals();
    final firstDayOfWeek = getFirstDayOfCurrentWeek();

    calendarFoodData = [];

    for (int i = 0; i < 14; i++) {
      weekCells = [];
      // Every day
      final currentDay = firstDayOfWeek.add(Duration(days: i));

      for (int j = 0; j < meals.length; j++) {
        final result = calendarCellsInDb
            .where((e) => isSameDate(e.date, currentDay))
            .where((e) => e.mealId == meals[j].id)
            .toList();

        if (result.isNotEmpty) {
          weekCells.add(
            FilledCalendarCell(
              recipeId: result.first.recipeId,
              mealId: result.first.mealId,
              date: result.first.date,
              recipeName: result.first.recipeName,
            ),
          );
        } else {
          weekCells.add(EmptyCalendarCell(
            date: currentDay,
            mealId: meals[j].id,
          ));
        }
      }

      calendarFoodData.add(weekCells);
    }

    update();
  }

  Future insertRecipeInCalendar(FilledCalendarCell calendar) async {
    final insertSuccess =
        await _calendarManager.insertRecipeInCalendar(calendar);

    print("date: ${calendar.date}");
  }

  Future updateRecipeInCalendar(FilledCalendarCell calendar) async {
    final updateSuccess =
        await _calendarManager.updateRecipeInCalendar(calendar);

    print("");
  }

  Future<bool> deleteRecipeInCalendar({required int recipeId}) async {
    return await _calendarManager.deleteRecipeInCalendar(recipeId);
  }

  void changeWeekDisplayed(CalendarWeekDisplayed weekDisplayed) {
    this.weekDisplayed = weekDisplayed;
    update();
  }

  Future<bool> isRecipeInCalendarBetweenDates({required int recipeId}) async {
    return await _calendarManager.isRecipeInCalendarBetweenDates(
      recipeId: recipeId,
    );
  }
}
