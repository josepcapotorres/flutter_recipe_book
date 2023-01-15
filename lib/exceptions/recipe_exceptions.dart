class RelationRecipeMealException implements Exception {
  final String message;

  RelationRecipeMealException(this.message);
}

class SaveNewRecipeException implements Exception {
  final String message;

  SaveNewRecipeException(this.message);
}

class DeleteRecipeException implements Exception {
  final String message;

  DeleteRecipeException(this.message);
}

class UpdateRecipeDataException implements Exception {
  final String message;

  UpdateRecipeDataException(this.message);
}
