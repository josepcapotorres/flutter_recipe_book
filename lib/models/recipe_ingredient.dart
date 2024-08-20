class RecipeIngredient {
  int? id;
  late int idIngredient;
  String? ingredientName;
  late String unit;
  late double quantityIngredient;
  late int idRecipe;

  RecipeIngredient.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    idIngredient = json["idIngredient"];
    ingredientName = json["ingredient_name"];
    unit = json["unit"];
    quantityIngredient = json["quantityIngredient"];

    if (json.containsKey("idRecipe")) {
      idRecipe = json["idRecipe"];
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "idIngredient": idIngredient,
      "unit": unit,
      "quantityIngredient": quantityIngredient,
      "idRecipe": idRecipe,
    };
  }
}
