import 'package:flutter_myrecipesapp/views/widgets/loading_dialog.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class BaseController extends GetxController {
  String? validateEmptyField(String? text) {
    if (text == null) {
      return translate("validations.unknown_error");
    } else if (text.isNotEmpty) {
      return null;
    } else {
      return translate("validations.empty_field");
    }
  }

  void showLoadingDialog({String? message}) {
    if (Get.isDialogOpen == null) {
      Get.dialog(LoadingDialog(message), barrierDismissible: false);
    } else if (Get.isDialogOpen != null && !Get.isDialogOpen!) {
      Get.dialog(LoadingDialog(message), barrierDismissible: false);
    }
  }

  void hideLoadingDialog() {
    if (Get.isDialogOpen == null) {
      Get.back();
    } else if (Get.isDialogOpen != null && Get.isDialogOpen!) {
      Get.back();
    }
  }
}
