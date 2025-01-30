// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kokiku/datas/models/remote/category.dart';
// import 'package:kokiku/datas/models/remote/shopping_list_item.dart';
// import 'package:kokiku/presentations/blocs/shopping_list/shopping_list_bloc.dart';
// import 'package:kokiku/presentations/widgets/category_dropdown.dart';
//
// class CreateNewShoppingListItemPage extends StatefulWidget {
//   final List<ItemCategory>? categories;
//
//   const CreateNewShoppingListItemPage({
//     this.categories,
//     super.key,
//   });
//
//   @override
//   State<CreateNewShoppingListItemPage> createState() =>
//       _CreateNewShoppingListItemPageState();
// }
//
// class _CreateNewShoppingListItemPageState extends State<CreateNewShoppingListItemPage> {
//   final formKey = GlobalKey<FormState>();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   ItemCategory? selectedCategory;
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<ShoppingListBloc>().add(LoadShoppingList());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Add Shopping List Item'),
//       ),
//       body: SafeArea(
//         child: BlocListener<ShoppingListBloc, ShoppingListState>(
//           listener: (context, state) {
//             if (state is ShoppingListError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.message)),
//               );
//             }
//           },
//           child: BlocBuilder<ShoppingListBloc, ShoppingListState>(
//             builder: (context, state) {
//               if (state is ShoppingListLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state is ShoppingListLoaded) {
//                 return SingleChildScrollView(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: formKey,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CategoryDropdown(
//                           categories: state.categories,
//                           selectedCategory: selectedCategory,
//                           onChanged: (value) {
//                             if (value?.id == 'add') {
//                               _showAddCategoryModal(context);
//                             } else {
//                               setState(() => selectedCategory = value);
//                             }
//                           },
//                         ),
//                         const SizedBox(height: 16),
//
//                         // Name Text Field
//                         _buildTextField('Name', nameController, 'Enter a name'),
//                         const SizedBox(height: 16),
//
//                         // Description
//                         _buildTextField('Description', descriptionController, null),
//                         const SizedBox(height: 16),
//
//                         // Submit Button
//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               padding: const EdgeInsets.symmetric(vertical: 16),
//                             ),
//                             onPressed: () {
//                               if (formKey.currentState!.validate()) {
//                                 context.read<ShoppingListBloc>().add(
//                                     CreateShoppingListItem(ShoppingListItem(
//                                       name: nameController.text,
//                                       description: descriptionController.text,
//                                       categoryId: selectedCategory?.id ?? '',
//                                     ))
//                                 );
//                                 Navigator.pop(context);
//                               }
//                             },
//                             child: const Text('Add Item'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }
//
//               return Container();
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String label, TextEditingController controller, String? validationMessage, {bool isNumber = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//           validator: (value) {
//             if (value == null || value.trim().isEmpty) {
//               return validationMessage;
//             }
//             if (isNumber && int.tryParse(value) == null) {
//               return 'Please enter a valid number.';
//             }
//             return null;
//           },
//           decoration: InputDecoration(
//             hintText: validationMessage,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _showAddCategoryModal(BuildContext context) {
//     final controller = TextEditingController();
//
//     showBottomSheet(
//       context: context,
//       builder: (_) => Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Create Category'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: 'Enter category name',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                 ),
//                 onPressed: () {
//                   context.read<ItemBloc>().add(AddCategory(controller.text.trim()));
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Add'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
