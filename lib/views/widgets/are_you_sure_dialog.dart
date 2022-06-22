import 'package:flutter/material.dart';

class AreYouSureDialog extends StatelessWidget {
  final String text;
  final VoidCallback onYes;
  final VoidCallback onNo;

  AreYouSureDialog({
    this.text = "Estàs segur de realizar aquesta acció?",
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(text),
      actions: [
        TextButton(
          child: Text("Si"),
          onPressed: onYes,
        ),
        TextButton(
          child: Text("No"),
          onPressed: onNo,
        ),
      ],
    );
  }
}
