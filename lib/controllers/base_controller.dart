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
}
