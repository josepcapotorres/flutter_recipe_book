import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/controllers.dart';
import 'package:flutter_myrecipesapp/models/models.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

import '../widgets/are_you_sure_dialog.dart';
import '../widgets/base_page.dart';

class IngredientsPage extends StatelessWidget {
  static const routeName = "ingredients";

  const IngredientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      Get.find<IngredientController>().getIngredients();
    });

    return BasePage(
      appBar: AppBar(
        title: Text(translate("ingredients_page.title")),
      ),
      body: GetBuilder<IngredientController>(
        builder: (ctrl) {
          if (ctrl.loading) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (ctrl.ingredients.isNotEmpty) {
            return ListView.separated(
              itemCount: ctrl.ingredients.length,
              separatorBuilder: (_, __) => Divider(),
              itemBuilder: (_, i) => _Ingredient(
                ctrl.ingredients[i],
              ),
            );
          }

          return Center(
            child: Text(translate("common.no_results")),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showAdaptiveDialog(
          context: context,
          builder: (_) => _AddIngredientDialog(),
        ),
      ),
    );
  }
}

class _Ingredient extends StatelessWidget {
  final _ingredientsController = Get.find<IngredientController>();
  final Ingredient ingredient;

  _Ingredient(this.ingredient);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(ingredient.name ?? "-"),
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: (_) => _AddIngredientDialog(ingredient: ingredient),
        );
      },
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (ingredient.id! == 0) {
            Get.rawSnackbar(
              message: translate("meals_page.cannot_del_meal"),
            );

            return;
          }

          Get.dialog(
            AreYouSureDialog(
              onYes: () {
                _ingredientsController.deleteIngredient(ingredient.id!);
                Get.back();
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddIngredientDialog extends StatelessWidget {
  final _ingredientsController = Get.find<IngredientController>();
  final _ingredientsEditingCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Ingredient? ingredient;

  _AddIngredientDialog({this.ingredient}) {
    if (ingredient != null) {
      _ingredientsEditingCtrl.text = ingredient!.name ?? "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: translate("ingredients_page.ingredient_name"),
              ),
              controller: _ingredientsEditingCtrl,
              validator: _ingredientsController.validateEmptyField,
              autofocus: true,
              onEditingComplete: () async {
                final formState = _formKey.currentState;

                if (formState?.validate() ?? false) {
                  formState?.save();

                  await _createOrUpdateIngredient();

                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: _ButtonText(ingredient),
          onPressed: () async {
            if (ingredient != null && ingredient!.id! == 0) {
              Get.rawSnackbar(
                message: translate(
                  "meals_page.cannot_modify_meal",
                ),
              );

              return;
            }

            final formState = _formKey.currentState;

            if (formState?.validate() ?? false) {
              formState?.save();

              await _createOrUpdateIngredient();

              Get.back();
            }
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(translate("common.cancel").toUpperCase()),
        ),
      ],
    );
  }

  Future<void> _createOrUpdateIngredient() async {
    if (ingredient != null) {
      // Call update existing meal
      ingredient!.name = _ingredientsEditingCtrl.text.trim();
      await _ingredientsController.updateMeal(ingredient!);
    } else {
      // Call insert new meal
      final ing = Ingredient();
      ing.name = _ingredientsEditingCtrl.text;

      await _ingredientsController.newIngredient(ing);
    }
  }
}

class _ButtonText extends StatelessWidget {
  final Ingredient? ingredient;

  const _ButtonText(this.ingredient);

  @override
  Widget build(BuildContext context) {
    String buttonText;

    if (ingredient == null) {
      buttonText = translate("ingredients_page.add_ingredient");
    } else {
      buttonText = translate("ingredients_page.modify_ingredient");
    }

    return Text(buttonText.toUpperCase());
  }
}
