class CalendarCell {
  late DateTime date;
  int? mealId;

  CalendarCell({
    required this.date,
    required this.mealId,
  });

  bool get isEmptyCell => this is EmptyCalendarCell;
}

class FilledCalendarCell extends CalendarCell {
  int? id;
  int? recipeId;
  int? mealId;
  late DateTime date;
  late String recipeName;

  FilledCalendarCell({
    this.id,
    required this.recipeId,
    required this.mealId,
    required this.recipeName,
    required this.date,
  }) : super(date: date, mealId: mealId);

  bool get isRecipeEmpty {
    return this is EmptyCalendarCell;
  }

  /// TOT TIPUS DE CEL·LA NECESSITA TENIR LA DATA.
  /// AIXÍ, PER PANTALLA SORTIRÀ EL NOM DEL DIA SEMPRE

  factory FilledCalendarCell.fromJson(Map<String, dynamic> json) {
    return FilledCalendarCell(
      id: json["id"],
      recipeId: json["recipe_id"],
      mealId: json["meal_id"],
      recipeName: json.containsKey("recipe_name") ? json["recipe_name"] : "",
      date: DateTime.parse(json["date"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "recipe_id": recipeId,
      "meal_id": mealId,
      "date": date.toString(),
    };
  }
}

class EmptyCalendarCell extends CalendarCell {
  DateTime date;
  int? mealId;

  EmptyCalendarCell({
    required this.date,
    required this.mealId,
  }) : super(date: date, mealId: mealId);
}
