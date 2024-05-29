import 'package:flutter/material.dart';

class FilterByAlertDialog extends StatefulWidget {
  const FilterByAlertDialog({super.key});

  @override
  State<FilterByAlertDialog> createState() => _FilterByAlertDialogState();
}

class _FilterByAlertDialogState extends State<FilterByAlertDialog> {
  bool? isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter By:'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CategoryDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: AircraftDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: StatusDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: RoleDropdown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CrewTextField(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: PickDateRange(),
          )
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel')),
        TextButton(onPressed: () {}, child: const Text('Apply'))
      ],
    );
  }
}

class CrewTextField extends StatelessWidget {
  const CrewTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          label: const Text('Crew'),
          border: const OutlineInputBorder(),
          suffixIcon:
              IconButton(onPressed: () {}, icon: const Icon(Icons.search))),
    );
  }
}

class RoleDropdown extends StatelessWidget {
  const RoleDropdown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DropdownMenu(
      expandedInsets: EdgeInsets.all(0),
      label: Text('Role'),
      dropdownMenuEntries: <DropdownMenuEntry>[
        DropdownMenuEntry(value: 'All', label: 'All'),
        DropdownMenuEntry(
          value: 'Pilots',
          label: 'Pilots',
        ),
        DropdownMenuEntry(
          value: 'Engineers',
          label: 'Engineers',
        ),
        DropdownMenuEntry(
          value: 'Flight Attendants',
          label: 'Flight Attendants',
        ),
        DropdownMenuEntry(
          value: 'Other Personnel',
          label: 'Other Personnel',
        ),
      ],
    );
  }
}

class StatusDropDown extends StatelessWidget {
  const StatusDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DropdownMenu(
      expandedInsets: EdgeInsets.all(0),
      label: Text('Status'),
      dropdownMenuEntries: <DropdownMenuEntry>[
        DropdownMenuEntry(value: 'All', label: 'All'),
        DropdownMenuEntry(
          value: 'Active',
          label: 'Active',
        ),
        DropdownMenuEntry(
          value: 'Archived',
          label: 'Archived',
        )
      ],
    );
  }
}

class AircraftDropDown extends StatelessWidget {
  const AircraftDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DropdownMenu(
      expandedInsets: EdgeInsets.all(0),
      label: Text('Aircraft'),
      dropdownMenuEntries: <DropdownMenuEntry>[
        DropdownMenuEntry(value: 'All', label: 'All'),
        DropdownMenuEntry(
          value: 'VQ-BOS',
          label: 'VQ-BOS',
        ),
        DropdownMenuEntry(
          value: 'VP-BLU',
          label: 'VP-BLU',
        )
      ],
    );
  }
}

class CategoryDropDown extends StatelessWidget {
  const CategoryDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DropdownMenu(
      expandedInsets: EdgeInsets.all(0),
      label: Text('Category'),
      dropdownMenuEntries: <DropdownMenuEntry>[
        DropdownMenuEntry(value: 'All', label: 'All'),
        DropdownMenuEntry(
          value: 'Crew documents',
          label: 'Crew documents',
          trailingIcon: Icon(Icons.arrow_right_outlined),
        ),
        DropdownMenuEntry(
          value: 'Aircraft documents',
          label: 'Aircraft documents',
          trailingIcon: Icon(Icons.arrow_right_outlined),
        )
      ],
    );
  }
}

class PickDateRange extends StatefulWidget {
  const PickDateRange({
    super.key,
  });

  @override
  State<PickDateRange> createState() => _PickDateRangeState();
}

class _PickDateRangeState extends State<PickDateRange> {
  DateTimeRange? _dateTimeRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: () async {
          _dateTimeRange = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              initialDateRange: _dateTimeRange,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: 500, maxHeight: 800),
                      child: child,
                    )
                  ],
                );
              });
          setState(() {});
        },
        child: Text(
          _dateTimeRange == null
              ? "Select a date range"
              // need to modify for readable string
              : "${_dateTimeRange!.start.toIso8601String()} - ${_dateTimeRange!.end.toIso8601String()}",
        ),
      ),
    );
  }
}
