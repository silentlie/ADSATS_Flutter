import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class RoleRecipientsMultiSelect extends StatelessWidget {
  const RoleRecipientsMultiSelect ({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.all(5),
      child: MultiSelectDropDown(
        searchEnabled: true,
        onOptionSelected: (options) {
          debugPrint(options.toString());
        }, 
        options: const <ValueItem> [
          ValueItem(label: 'Engineers', value: 'Engineers'),
          ValueItem(label: 'Pilots', value: 'Pilots'),
          ValueItem(label: 'Cabin Attendants', value: 'Cabin Attendants'),
          ValueItem(label: 'Personnel', value: 'Personnel'),
        ],
        maxItems: null,
        selectionType: SelectionType.multi,
        selectedOptionIcon: const Icon(Icons.check_circle),
        hint: 'Select a Role',
      ),
    );
  }
}

class PlanesRecepientsMultiSelect extends StatelessWidget {
  const PlanesRecepientsMultiSelect({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      padding: const EdgeInsets.all(5),
      child: MultiSelectDropDown(
        searchEnabled: true,
        onOptionSelected: (options) {
          debugPrint(options.toString());
        }, 
        options: const <ValueItem> [
          ValueItem(label: 'Aircraft 1', value: 'Aircraft 1'),
          ValueItem(label: 'Aircraft 2', value: 'Aircraft 2'),
          ValueItem(label: 'Aircraft 3', value: 'Aircraft 3'),
          ValueItem(label: 'Aircraft 4', value: 'Aircraft 4'),
        ],
        maxItems: null,
        selectionType: SelectionType.multi,
        selectedOptionIcon: const Icon(Icons.check_circle),
        hint: 'Select an aircraft',
      ),
    );
  }
}

class RecepientMultiSelect extends StatelessWidget {
  const RecepientMultiSelect ({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.3,
      padding: const EdgeInsets.all(5),
      child: MultiSelectDropDown(
        searchEnabled: true,
        onOptionSelected: (options) {
          debugPrint(options.toString());
        }, 
        options: const <ValueItem> [
          ValueItem(label: 'Staff 1', value: 'Staff 1'),
          ValueItem(label: 'Staff 2', value: 'Staff 2'),
          ValueItem(label: 'Staff 3', value: 'Staff 3'),
          ValueItem(label: 'Staff 4', value: 'Staff 4'),
        ],
        maxItems: null,
        selectionType: SelectionType.multi,
        selectedOptionIcon: const Icon(Icons.check_circle),
        hint: 'Select a staff',
      ),
    );
  }
}