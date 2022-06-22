import 'package:flutter/material.dart';

import 'drawer_menu.dart';

class BasePage extends StatelessWidget {
  final AppBar appBar;
  final Widget body;
  final Widget? floatingActionButton;

  BasePage({
    required this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: SafeArea(
        child: DrawerMenu(),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
