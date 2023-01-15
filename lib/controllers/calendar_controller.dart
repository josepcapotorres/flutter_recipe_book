import 'package:flutter_myrecipesapp/controllers/database_controller.dart';
import 'package:flutter_myrecipesapp/enums/calendar_week_displayed.dart';
import 'package:flutter_myrecipesapp/models/calendar_cell.dart';
import 'package:get/get.dart';

import '../helpers/date_time_helper.dart';

class CalendarController extends GetxController {
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
  /*[
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dilluns berenar. Primer dia setmana actual",
        //"Costelles as forn amb patates i pa ratllat amb oli i sal. 1 1",
      ),
      //EmptyCalendarCell(),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dilluns dinar",
        //"Costelles as forn amb patates i pa ratllat amb oli i sal. 1 1",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dilluns sopar",
        //"Costelles as forn amb patates i pa ratllat amb oli i sal. 1 1",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dimarts berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dimarts dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dimarts sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dimecres berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dimecres dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dimecres sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dijous berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dijous dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual Dijous sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual divendres berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual divendres dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual divendres sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual dissabte berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual dissabte dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual dissabte sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual diumenge berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual diumenge dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M actual diumenge sopar. Darrer dia setmana actual",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dilluns berenar. Primer dia setmana següent",
        //"Costelles as forn amb patates i pa ratllat amb oli i sal. 1 1",
      ),
      //EmptyCalendarCell(),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dilluns dinar",
        //"Costelles as forn amb patates i pa ratllat amb oli i sal. 1 1",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dilluns sopar",
        //"Costelles as forn amb patates i pa ratllat amb oli i sal. 1 1",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dimarts berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dimarts dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dimarts sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dimecres berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dimecres dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dimecres sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dijous berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dijous dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent Dijous sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent divendres berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent divendres dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent divendres sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent dissabte berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent dissabte dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent dissabte sopar",
      ),
    ],
    [
      FilledCalendarCell(
        recipeId: 1,
        mealId: 1,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent diumenge berenar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 2,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent diumenge dinar",
      ),
      FilledCalendarCell(
        recipeId: 1,
        mealId: 3,
        date: DateTime(2022, 10, 24),
        recipeName: "M següent diumenge sopar. Darrer dia setmana següent",
      ),
    ],
  ];*/

  void getCalendarData() async {
    List<CalendarCell> weekCells;
    List<FilledCalendarCell> calendarCellsInDb =
        await DBController.instance.getCalendarData();

    final meals = await DBController.instance.getMeals();
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
          weekCells.add(EmptyCalendarCell(date: currentDay));
        }
      }

      calendarFoodData.add(weekCells);
    }

    update();
  }

  Future insertRecipeInCalendar(FilledCalendarCell calendar) async {
    final insertSuccess =
        await DBController.instance.insertRecipeInCalendar(calendar);

    print("");
  }

  Future<bool> deleteRecipeInCalendar({required int recipeId}) async {
    return await DBController.instance.deleteRecipeInCalendar(recipeId);
  }

  void changeWeekDisplayed(CalendarWeekDisplayed weekDisplayed) {
    this.weekDisplayed = weekDisplayed;
    update();
  }
}
