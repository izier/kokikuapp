
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';

class AccessIdDropdown extends StatelessWidget {
  final List<AccessId> accessIds;
  final AccessId? selectedAccessId;
  final Function(AccessId?) onChanged;

  const AccessIdDropdown({
    super.key,
    required this.accessIds,
    required this.selectedAccessId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Access ID',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<AccessId>(
          selectedItem: selectedAccessId,
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          items: (filter, infiniteScrollProps) => [
            ...accessIds.map((e) => e)
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
              hintText: 'Select an access id',
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
