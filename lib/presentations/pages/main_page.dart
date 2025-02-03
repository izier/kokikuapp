import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/constants/variables/theme.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/user.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
import 'package:kokiku/presentations/pages/home/home_page.dart';
import 'package:kokiku/presentations/pages/inventory/inventory_page.dart';
import 'package:kokiku/presentations/pages/profile/profile_page.dart';
import 'package:kokiku/presentations/pages/shopping_list/shopping_list_page.dart';
import 'package:kokiku/presentations/widgets/access_id_dropdown.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';

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
        onPressed: () async {
          if (_selectedIndex == 2) {
            // Show a dialog to add a new shopping list
            _showAddShoppingListDialog(context);
          } else {
            final localization = LocalizationService.of(context)!;
            final user = FirebaseAuth.instance.currentUser;
            final firestore = FirebaseFirestore.instance;
            List<String> userAccessIds = [];

            final userSnapshot = await firestore
                .collection('users')
                .doc(user!.uid)
                .get();

            final userModel = UserModel.fromFirestore(userSnapshot.data()!, user.uid);
            userAccessIds = userModel.accessIds;

            if (userAccessIds.isEmpty) {
              showErrorToast(
                  context: context,
                  title: localization.translate('no_access_id'),
                  message: localization.translate('no_access_id_sub')
              );
              return;
            }
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

  void _showAddShoppingListDialog(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final localization = LocalizationService.of(context)!;
    AccessId? selectedAccessId;
    List<String> userAccessIds = [];
    List<AccessId> accessIds = [];

    final shoppingListBloc = context.read<ShoppingListBloc>();

    final userSnapshot = await firestore
        .collection('users')
        .doc(user!.uid)
        .get();

    final userModel = UserModel.fromFirestore(userSnapshot.data()!, user.uid);
    userAccessIds = userModel.accessIds;

    if (userAccessIds.isEmpty) {
      showErrorToast(
        context: context,
        title: localization.translate('no_access_id'),
        message: localization.translate('no_access_id_sub')
      );
      return;
    }

    final accessSnapshot = await firestore
        .collection('accessIds')
        .where(FieldPath.documentId, whereIn: userAccessIds)
        .get();

    accessIds = accessSnapshot.docs
        .map((doc) => AccessId.fromFirestore(doc))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Shopping List'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccessIdDropdown(
                accessIds: accessIds,
                selectedAccessId: selectedAccessId,
                onChanged: (value) {
                  setState(() => selectedAccessId = value);
                },
              ),
              const SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  // Use the stored bloc instead of accessing context after pop
                  shoppingListBloc.add(
                    AddShoppingList(
                      name: nameController.text,
                      description: nameController.text,
                      accessId: selectedAccessId!.id, // Optional field
                    ),
                  );
                  Navigator.pop(context);
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
