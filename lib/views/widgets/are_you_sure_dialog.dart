import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get/get.dart';

class AreYouSureDialog extends StatelessWidget {
  final String? text;
  final VoidCallback onYes;
  final VoidCallback? onNo;

  AreYouSureDialog({
    this.text,
    required this.onYes,
    this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(text ?? translate("common.are_you_sure")),
      actions: [
        TextButton(
          child: Text(translate("common.yes")),
          onPressed: onYes,
        ),
        TextButton(
          child: Text(translate("common.no")),
          onPressed: onNo ?? Get.back,
        ),
      ],
    );
  }
}
