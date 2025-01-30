import 'dart:developer';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/pages/home/home_page.dart';
import 'package:kokiku/presentations/pages/inventory/inventory_page.dart';
import 'package:kokiku/presentations/pages/profile/profile_page.dart';
import 'package:kokiku/presentations/pages/shopping_list/shopping_list_detail_page.dart';
import 'package:kokiku/presentations/pages/shopping_list/shopping_list_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of screens for each tab
  final List<Widget> _screens = [
    HomePage(),
    InventoryPage(),
    ShoppingListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () {
          if (_selectedIndex == 2) {
            // Show a dialog to add a new shopping list
            _showAddShoppingListDialog(context);
          } else {
            Navigator.pushNamed(context, '/addedit').whenComplete((){
              context.read<InventoryBloc>().add(LoadInventory());
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        activeColor: AppTheme.primaryColor,
        inactiveColor: Theme.of(context).disabledColor,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        icons: [
          Icons.home,
          Icons.kitchen,
          Icons.shopping_bag,
          Icons.person,
        ],
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        scaleFactor: 0,
        splashRadius: 0,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  void _showAddShoppingListDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController(); // New controller for description
    final shoppingListBloc = context.read<ShoppingListBloc>(); // Store the bloc before showing the dialog

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Shopping List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Shopping List Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description (Optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Use the stored bloc instead of accessing context after pop
                  shoppingListBloc.add(
                    AddShoppingList(
                      name: nameController.text,
                      description: nameController.text, // Optional field
                    ),
                  );
                  Navigator.pop(context); // Close the dialog first

                  // Navigate to the new shopping list detail page
                  Future.delayed(Duration(milliseconds: 100), () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ShoppingListDetailPage(
                    //       shoppingListId: "new_id", // Update this with the actual ID
                    //       shoppingListName: nameController.text,
                    //       shoppingListDescription: descriptionController.text,
                    //     ),
                    //   ),
                    // ).whenComplete(() {
                    //   shoppingListBloc.add(LoadShoppingList());
                    // });
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }


}
