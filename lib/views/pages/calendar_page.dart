import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/calendar_controller.dart';
import 'package:flutter_myrecipesapp/controllers/database_controller.dart';
import 'package:flutter_myrecipesapp/controllers/recipe_controller.dart';
import 'package:flutter_myrecipesapp/enums/calendar_week_displayed.dart';
import 'package:flutter_myrecipesapp/models/calendar_cell.dart';
import 'package:flutter_myrecipesapp/views/pages/recipe_detail_page.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../models/meals.dart';

class CalendarPage extends StatelessWidget {
  static final String routeName = "calendar_page";

  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemsWidth = 150.0;
    final calendarController = Get.find<CalendarController>();
    calendarController.getCalendarData();

    return BasePage(
      appBar: AppBar(
        title: Text(
          translate("calendar_page.title"),
        ),
      ),
      body: Column(
        children: [
          _CalendarWeekChanger(),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FixedColumns(itemsWidth: itemsWidth),
                  _ScrollableTable(itemsWidth: itemsWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWeekChanger extends StatelessWidget {
  const _CalendarWeekChanger({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarController = Get.find<CalendarController>();

    return GetBuilder<CalendarController>(
      builder: (_) {
        if (_.calendarFoodData.isEmpty) {
          return Container();
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: calendarController.isDisplayingCurrWeek
                  ? null
                  : () => _.changeWeekDisplayed(
                        CalendarWeekDisplayed.currentWeek,
                      ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: calendarController.isDisplayingNextWeek
                  ? null
                  : () => _.changeWeekDisplayed(
                        CalendarWeekDisplayed.nextWeek,
                      ),
            ),
          ],
        );
      },
    );
  }
}

class _FixedColumns extends StatelessWidget {
  final double itemsWidth;

  _FixedColumns({required this.itemsWidth});

  @override
  Widget build(BuildContext context) {
    final calendarCtrl = Get.find<CalendarController>();

    return GetBuilder<CalendarController>(
      builder: (_) {
        return Row(
          children: calendarCtrl.calendarWeekData
              .map((e) =>
                  _HeaderItem(date: e.first.date, itemsWidth: itemsWidth))
              .toList(),
        );
      },
    );
  }
}

class _HeaderItem extends StatelessWidget {
  final DateTime date;
  final double itemsWidth;

  const _HeaderItem({
    required this.date,
    required this.itemsWidth,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, d");

    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        width: itemsWidth,
        child: Text(
          dateFormat.format(date),
          style: TextStyle(
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ScrollableTable extends StatelessWidget {
  final double itemsWidth;

  const _ScrollableTable({required this.itemsWidth});

  @override
  Widget build(BuildContext context) {
    final calendarController = Get.find<CalendarController>();

    return GetBuilder<CalendarController>(
      builder: (_) {
        if (calendarController.calendarFoodData.isEmpty) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              children: calendarController.calendarWeekData
                  .map((e) => _CalendarWeek(
                        calendarWeekData: e,
                        cardSize: itemsWidth,
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarWeek extends StatelessWidget {
  final List<CalendarCell> calendarWeekData;
  final double cardSize;

  const _CalendarWeek({
    Key? key,
    required this.calendarWeekData,
    required this.cardSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...calendarWeekData
            .map((day) => _CalendarItem(
                  recipeDay: day,
                  cardSize: cardSize,
                ))
            .toList(),
      ],
    );
  }
}

class _CalendarItem extends StatelessWidget {
  final CalendarCell recipeDay;
  final double cardSize;

  const _CalendarItem({
    required this.recipeDay,
    required this.cardSize,
  });

  @override
  Widget build(BuildContext context) {
    final recipeController = Get.find<RecipeController>();

    return GestureDetector(
      onTap: () async {
        if (recipeDay is FilledCalendarCell) {
          final currentCalendarCell = recipeDay as FilledCalendarCell;
          // Navigation needs the Recipe obj class
          final currentRecipe = await recipeController.getRecipeById(
            currentCalendarCell.recipeId!,
          );

          if (currentRecipe != null) {
            Navigator.pushNamed(
              context,
              RecipeDetailPage.routeName,
              arguments: currentRecipe,
            );
          }
        } else {
          Get.rawSnackbar(message: translate("calendar_page.no_recipe"));
        }
      },
      child: Card(
        child: Container(
          padding: EdgeInsets.all(8),
          height: cardSize,
          width: cardSize,
          child: Column(
            children: [
              _CalendarItemName(recipeDay: recipeDay),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Divider(color: Color(0xFFBBBBBB)),
              ),
              _MealName(recipeDay: recipeDay),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarItemName extends StatelessWidget {
  final CalendarCell recipeDay;

  const _CalendarItemName({
    required this.recipeDay,
  });

  @override
  Widget build(BuildContext context) {
    String msgText;
    Color? color;

    if (recipeDay is EmptyCalendarCell) {
      msgText = translate("calendar_page.no_recipe");
      color = Colors.grey;
    } else if (recipeDay is FilledCalendarCell) {
      msgText = ((recipeDay) as FilledCalendarCell).recipeName;
    } else {
      msgText = "";
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          msgText,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _MealName extends StatelessWidget {
  final CalendarCell recipeDay;

  const _MealName({required this.recipeDay});

  @override
  Widget build(BuildContext context) {
    String mealName;

    if (recipeDay is FilledCalendarCell) {
      final filledCalendarCell = recipeDay as FilledCalendarCell;

      return FutureBuilder(
        future: DBController.instance.getMealById(filledCalendarCell.mealId!),
        builder: (_, AsyncSnapshot<Meal?> snapshot) {
          if (snapshot.hasData)
            return Text(snapshot.data!.name);
          else
            return Text("No especificado");
        },
      );
    } else {
      return Text("No especificado");
    }
  }
}
