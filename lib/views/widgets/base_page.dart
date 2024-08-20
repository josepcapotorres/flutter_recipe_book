import 'package:flutter/material.dart';

import 'drawer_menu.dart';

class BasePage extends StatelessWidget {
  final AppBar appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final EdgeInsets? padding;

  BasePage(
      {required this.appBar,
      required this.body,
      this.floatingActionButton,
      this.padding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: SafeArea(
        child: DrawerMenu(),
      ),
      body: Padding(
        padding: padding ?? EdgeInsets.only(right: 15, bottom: 15, left: 15),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
