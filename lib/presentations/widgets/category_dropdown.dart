import 'package:flutter/material.dart';
import 'package:kokiku/datas/models/remote/category.dart';

class CategoryDropdown extends StatelessWidget {
  final List<ItemCategory> categories;
  final String? selectedCategory;
  final Function(String?) onChanged;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          items: [
            ...categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.name,
                child: Text(category.name),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'add',
              child: Text('Add New Category'),
            ),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value == null || value.isEmpty ? 'Select a category' : null,
        ),
      ],
    );
  }
}
