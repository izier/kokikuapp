import 'package:flutter/material.dart';
import 'package:kokiku/datas/models/remote/sublocation.dart';

class SublocationDropdown extends StatelessWidget {
  final List<Sublocation> sublocations;
  final String? selectedSublocation;
  final Function(String?) onChanged;
  final dynamic selectedLocation;

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
      return const SizedBox(); // Return empty space if no location selected
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sublocation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedSublocation,
          items: [
            ...sublocations.map((sublocation) {
              return DropdownMenuItem<String>(
                value: sublocation.name,
                child: Text(sublocation.name),
              );
            }),
            const DropdownMenuItem<String>(
              value: 'add',
              child: Text('Add New Sublocation'),
            ),
          ],
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          validator: (value) =>
          value == null || value.isEmpty ? 'Select a sublocation' : null,
        ),
      ],
    );
  }
}
