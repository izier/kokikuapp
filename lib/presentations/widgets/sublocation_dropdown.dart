import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';

class SublocationDropdown extends StatelessWidget {
  final List<Sublocation> sublocations;
  final Sublocation? selectedSublocation;
  final Function(Sublocation?) onChanged;
  final Location? selectedLocation;

  const SublocationDropdown({
    super.key,
    required this.sublocations,
    required this.selectedSublocation,
    required this.onChanged,
    required this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedLocation == null) {
      return const SizedBox(); // Return empty space if no location is selected
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sublocation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<Sublocation>(
          selectedItem: selectedSublocation,
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          items: (filter, infiniteScrollProps) {
            return [
              Sublocation(id: 'add', locationId: 'add', name: 'Add New Sublocation', userId: 'add'), // Add new option
              ...sublocations.where((sublocation) => sublocation.locationId == selectedLocation!.id).map((e) => e)
            ];
          },
          itemAsString: (item) => item.name, // Display the name of sublocation
          onChanged: (Sublocation? selected) {
            onChanged(selected); // Call onChanged with Sublocation object
          },
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search sublocation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            showSearchBox: true,
            constraints: BoxConstraints(maxHeight: 300), // Adjust dropdown height
          ),
          enabled: true,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Select a sublocation',
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
