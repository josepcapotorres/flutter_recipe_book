import 'package:flutter_myrecipesapp/db/db.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/date_time_helper.dart';
import '../../models/models.dart';

class CalendarTable extends DatabaseManager {
  Future<List<Map<String, dynamic>>> getCalendar() async {
    final db = await database;

    final calendarData = await db?.query("calendar");

    if (calendarData == null) {
      return [];
    }

    return calendarData.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<FilledCalendarCell>> getCalendarData() async {
    final db = await database;

    final calendarData = await db?.rawQuery("""
      SELECT c.id, c.recipe_id, c.meal_id, r.name AS 'recipe_name', c.date
      FROM calendar c
      JOIN recipe r ON c.recipe_id = r.id 
    """) ?? [];

    return calendarData.map((e) => FilledCalendarCell.fromJson(e)).toList();
  }

  Future<bool> insertRecipeInCalendar(FilledCalendarCell calendar) async {
    final db = await database;
    final inserted = await db?.insert(
      "calendar",
      calendar.toJson(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    final prova = await db?.query("calendar");

    // TODO: id on db is stored as null. ARA NO DONA NULL
    return inserted != null && inserted > 0;
  }

  Future<bool> insertCalendarLine(Map<String, dynamic> calendarLine) async {
    final db = await database;

    final insertedRows = await db?.insert(
      "calendar",
      calendarLine,
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    return insertedRows != null ? insertedRows > 0 : false;
  }

  Future<bool> updateRecipeInCalendar(FilledCalendarCell calendar) async {
    final db = await database;
    final inserted = await db?.update(
      "calendar",
      calendar.toJson(),
      where: "id = ?",
      whereArgs: [calendar.id!],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    // TODO: id on db is stored as null. ARA NO DONA NULL
    return inserted != null && inserted > 0;
  }

  Future<bool> deleteRecipeInCalendar(int recipeId) async {
    final db = await database;

    final recipe = Get.find<RecipeTable>(); // From DataManager
    final recipeData = await recipe.getRecipeById(recipeId);

    if (recipeData == null) return false;

    final deleted = await db?.delete(
      "calendar",
      where: "id = ?",
      whereArgs: [recipeData.id!],
    );

    return deleted != null && deleted > 0;
  }

  Future<void> deleteOldCalendarEntries() async {
    final db = await database;

    final dateFormat = DateFormat("yyyy-MM-dd");

    final calendarData = await db?.rawQuery("""
      SELECT *
      FROM calendar c 
      WHERE date < ${dateFormat.format(DateTime.now())}
    """) ?? [];

    for (final calendarRow in calendarData) {
      final deleted = await db?.delete(
        "calendar",
        where: "id = ?",
        whereArgs: [
          calendarRow["id"],
        ],
      );
    }
  }

  Future<DateTime?> getDateIfRecipeInCalendarBetweenDates({
    required int recipeId,
  }) async {
    final db = await database;

    final firstDay = getFirstDayOfCurrentWeek();
    final lastDay = getLastDayOfNextWeek();

    final dateFormatter = DateFormat("yyyy-MM-dd");
    final strFirstDay = dateFormatter.format(firstDay);
    final strLastDay = dateFormatter.format(lastDay);

    final calendarResults = await db?.rawQuery("""
      SELECT c.* 
      FROM calendar c
      JOIN recipe r ON c.recipe_id = r.id
      WHERE date BETWEEN '$firstDay' AND '$lastDay'
        AND c.id = $recipeId""");

    if (calendarResults == null) return null;

    if (calendarResults.isEmpty) {
      return null;
    }

    final strDate = calendarResults.first["date"] as String;

    return DateTime.tryParse(strDate);
  }
}
