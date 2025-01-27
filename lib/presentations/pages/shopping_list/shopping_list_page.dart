import 'package:flutter/material.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ShoppingList Page')),
      body: Center(
        child: Text('Welcome to your app!'),
      ),
    );
  }
}
