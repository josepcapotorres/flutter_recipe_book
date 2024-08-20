import 'package:flutter/material.dart';
import 'package:flutter_myrecipesapp/controllers/food_categories_controller.dart';
import 'package:flutter_myrecipesapp/models/food_category.dart';
import 'package:flutter_myrecipesapp/views/widgets/are_you_sure_dialog.dart';
import 'package:flutter_myrecipesapp/views/widgets/base_page.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class FoodCategoriesPage extends StatefulWidget {
  static const String routeName = "food_categories";

  @override
  _FoodCategoriesPageState createState() => _FoodCategoriesPageState();
}

class _FoodCategoriesPageState extends State<FoodCategoriesPage> {
  final _foodCategoriesCtrl = Get.find<FoodCategoriesController>();

  @override
  void initState() {
    super.initState();

    _foodCategoriesCtrl.fetchFoodCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      appBar: AppBar(
        title: Text(translate("food_categories_page.title")),
      ),
      body: GetBuilder<FoodCategoriesController>(
        builder: (_) => _foodCategoriesCtrl.loading
            ? Center(
                child: CircularProgressIndicator.adaptive(),
              )
            : _foodCategoriesCtrl.categories.isNotEmpty
                ? ListView.separated(
                    itemCount: _foodCategoriesCtrl.categories.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (_, i) => _Category(
                      _foodCategoriesCtrl.categories[i],
                    ),
                  )
                : Center(
                    child: Text(translate("common.no_results")),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => showAdaptiveDialog(
          context: context,
          builder: (_) => _AddFoodCategoryDialog(),
        ),
      ),
    );
  }
}

class _Category extends StatelessWidget {
  final _foodCategoriesCtrl = Get.find<FoodCategoriesController>();
  final FoodCategory category;

  _Category(this.category);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.name),
      onTap: () {
        showAdaptiveDialog(
          context: context,
          builder: (_) => _AddFoodCategoryDialog(category: category),
        );
      },
      trailing: IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          if (category.id! == 0) {
            Get.rawSnackbar(
              message: translate("food_categories_page.cannot_del_category"),
            );

            return;
          }

          Get.dialog(
            AreYouSureDialog(
              onYes: () {
                _foodCategoriesCtrl.deleteFoodCategory(category.id!);
                Get.back();
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddFoodCategoryDialog extends StatelessWidget {
  final _foodCategoriesCtrl = Get.find<FoodCategoriesController>();
  final _foodCategoryCtrl = TextEditingController();
  final FoodCategory? category;
  final _formKey = GlobalKey<FormState>();

  _AddFoodCategoryDialog({this.category}) {
    if (category != null) {
      _foodCategoryCtrl.text = category!.name;
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
                labelText: translate("food_categories_page.category_name"),
              ),
              controller: _foodCategoryCtrl,
              validator: _foodCategoriesCtrl.validateEmptyField,
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: _ButtonText(category),
          onPressed: () {
            if (category != null && category!.id! == 0) {
              Get.rawSnackbar(
                message: translate(
                  "food_categories_page.cannot_modify_category",
                ),
              );

              return;
            }

            final formState = _formKey.currentState;

            if (formState?.validate() ?? false) {
              formState?.save();

              if (category != null) {
                // Call update existing category
                category!.name = _foodCategoryCtrl.text;
                _foodCategoriesCtrl.updateFoodCategory(category!);
              } else {
                // Call insert new category
                final foodCategory = FoodCategory();
                foodCategory.name = _foodCategoryCtrl.text;

                _foodCategoriesCtrl.newFoodCategory(foodCategory);
              }

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
}

class _ButtonText extends StatelessWidget {
  final FoodCategory? category;

  const _ButtonText(this.category);

  @override
  Widget build(BuildContext context) {
    String buttonText;

    if (category == null) {
      buttonText = translate("food_categories_page.add_category");
    } else {
      buttonText = translate("food_categories_page.modify_category");
    }

    return Text(buttonText.toUpperCase());
  }
}
