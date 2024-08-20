import 'package:get/get.dart';

bool isNumeric(String str) {
  return str.isNum;
}

String removeDecimalIfPossible(double number) {
  return number.toString().replaceAll(".0", "");
}
