import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/location.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';

class SublocationDropdown extends StatelessWidget {
  final List<Sublocation> sublocations;
  final Sublocation? selectedSublocation;
  final Function(Sublocation?) onChanged;
  final Location? selectedLocation;
  final AccessId? selectedAccessId;

  const SublocationDropdown({
    super.key,
    required this.sublocations,
    required this.selectedSublocation,
    required this.onChanged,
    required this.selectedLocation,
    required this.selectedAccessId,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!;
    
    if (selectedLocation == null || selectedAccessId == null) {
      return const SizedBox(); // Return empty space if no location is selected
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.translate('sublocation'),
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
              Sublocation(id: 'add', locationId: 'add', name: 'Add New Sublocation', accessId: 'add'), // Add new option
              ...sublocations.where((sublocation) => sublocation.locationId == selectedLocation!.id && sublocation.accessId == selectedAccessId!.id).map((e) => e)
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
                hintText: localization.translate('search'),
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
              hintText: localization.translate('select_sublocation'),
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
