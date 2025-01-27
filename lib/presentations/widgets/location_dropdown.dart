import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kokiku/datas/models/remote/location.dart';

class LocationDropdown extends StatelessWidget {
  final List<Location> locations;
  final Location? selectedLocation;
  final Function(Location?) onChanged;

  const LocationDropdown({
    super.key,
    required this.locations,
    required this.selectedLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<Location>(
          selectedItem: selectedLocation,
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          items: (filter, infiniteScrollProps) => [
            Location(id: 'add', name: 'Add New Location'), // Option for adding a new location
            ...locations.map((e) => e),
          ],
          itemAsString: (item) => item.name,
          onChanged: onChanged,
          popupProps: PopupProps.menu(
            fit: FlexFit.loose,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search location...',
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
              hintText: 'Select a location',
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
