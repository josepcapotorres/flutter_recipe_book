import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 15),
          Text(message ?? translate("common.loading")),
        ],
      ),
    );
  }
}
