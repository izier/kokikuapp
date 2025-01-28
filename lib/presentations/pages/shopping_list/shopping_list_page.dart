import 'package:flutter/material.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping List')),
      body: Center(
        child: Text('Welcome to your app!'),
      ),
    );
  }
}
