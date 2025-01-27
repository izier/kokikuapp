import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/pages/home/home_page.dart';
import 'package:kokiku/presentations/pages/inventory/inventory_page.dart';
import 'package:kokiku/presentations/pages/profile/profile_page.dart';
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
          Navigator.pushNamed(context, '/addedit').whenComplete((){
            context.read<InventoryBloc>().add(LoadInventory());
          });
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
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
