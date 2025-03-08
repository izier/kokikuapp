import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/category.dart';

class CategoryDropdown extends StatelessWidget {
  final List<ItemCategory> categories;
  final ItemCategory? selectedCategory;
  final Function(ItemCategory?) onChanged;
  final AccessId? selectedAccessId;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    required this.selectedAccessId
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!;

    if (selectedAccessId == null) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.translate('category'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<ItemCategory>(
          selectedItem: selectedCategory,
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          items: (filter, infiniteScrollProps) => [
            ItemCategory(id: 'add', name: 'Add Category', accessId: 'add'),
            ...categories.where((category) => category.accessId == selectedAccessId!.id).map((e) => e)
          ],
          itemAsString: (item) => item.name,
          onChanged: onChanged,
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: localization.translate('search'),
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
              hintText: localization.translate('select_category'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Add style to selected item text here
          dropdownBuilder: (context, selectedItem) {
            return Text(
              selectedItem?.name ?? '',
              style: const TextStyle(fontSize: 16), // Make text bigger here
            );
          },
        ),
      ],
    );
  }
}
