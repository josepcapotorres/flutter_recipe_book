class RecipeMeal {
  int? id;
  late int mealId;
  late int recipeId;

  RecipeMeal();

  RecipeMeal.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        mealId = json['mealId'],
        recipeId = json['recipeId'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealId': mealId,
        'recipeId': recipeId,
      };

  @override
  bool operator ==(Object other) {
    if (other is RecipeMeal) {
      return id == other.id &&
          mealId == other.mealId &&
          recipeId == other.recipeId;
    } else {
      return false;
    }
  }
}
