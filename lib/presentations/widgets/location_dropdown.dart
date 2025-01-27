import 'package:flutter/material.dart';
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Location>(
          value: selectedLocation,
          items: [
            ...locations.map((location) {
              return DropdownMenuItem<Location>(
                value: location,
                child: Text(location.name),
              );
            }),
            const DropdownMenuItem<Location>(
              value: null,
              child: Text('Add New Location'),
            ),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value == null ? 'Select a location' : null,
        ),
      ],
    );
  }
}
