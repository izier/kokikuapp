import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kokiku/datas/models/remote/category.dart';

class CategoryDropdown extends StatelessWidget {
  final List<ItemCategory> categories;
  final ItemCategory? selectedCategory;
  final Function(ItemCategory?) onChanged;

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
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<ItemCategory>(
          selectedItem: selectedCategory,
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          items: (filter, infiniteScrollProps) => [
            ItemCategory(id: 'add', name: 'Add Category', userId: 'add'),
            ...categories.map((e) => e)
          ],
          itemAsString: (item) => item.name,
          onChanged: onChanged,
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            showSearchBox: true,
            constraints: BoxConstraints(maxHeight: 300), // Adjust the height of the dropdown menu
          ),
          enabled: true,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Select a category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
