import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/datas/models/remote/location.dart';

class LocationDropdown extends StatelessWidget {
  final List<Location> locations;
  final Location? selectedLocation;
  final Function(Location?) onChanged;
  final bool? disableToAdd;
  final AccessId? selectedAccessId;

  const LocationDropdown({
    super.key,
    required this.locations,
    required this.selectedLocation,
    required this.onChanged,
    this.disableToAdd,
    required this.selectedAccessId,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!;
    List<Location> usedList;

    if (selectedAccessId == null) {
      return const SizedBox();
    }

    if (disableToAdd != null) {
      usedList = [
        ...locations.where((location) => location.accessId == selectedAccessId!.id).map((e) => e)
      ];
    } else {
      usedList = [
        Location(id: 'add', name: 'Add New Location', accessId: 'add'),
        ...locations.where((location) => location.accessId == selectedAccessId!.id).map((e) => e)
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.translate('location'),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownSearch<Location>(
          selectedItem: selectedLocation,
          compareFn: (item, selectedItem) => item.id == selectedItem.id,
          items: (filter, infiniteScrollProps) => usedList,
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
            constraints: BoxConstraints(maxHeight: 300), // Adjust dropdown height
          ),
          enabled: true,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: localization.translate('select_location'),
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
