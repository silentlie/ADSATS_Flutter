import 'package:adsats_flutter/route/documents_route/filter_by.dart';
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
            child: StatusDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DateRangeWidget(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: DueDateRangeWidget(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: AircraftDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TypeDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: ResolvedDropDown(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: AuthorTextField(),
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
          value: 'Read',
          label: 'Read',
        ),
        DropdownMenuEntry(
          value: 'Unread',
          label: 'Unread',
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

class DateRangeWidget extends StatelessWidget {
  const DateRangeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          label: const Text('Date'),
          border: const OutlineInputBorder(),
          suffixIcon:
              IconButton(
                onPressed: () {
                  showDateRangePicker(
                    context: context, 
                    firstDate: DateTime(2000), 
                    lastDate: DateTime.now(),
                    initialEntryMode: DatePickerEntryMode.input
                  );
                }, 
                icon: const Icon(Icons.calendar_month))),
    );
  }
}

class DueDateRangeWidget extends StatelessWidget {
  const DueDateRangeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          label: const Text('Due Date'),
          border: const OutlineInputBorder(),
          suffixIcon:
              IconButton(
                onPressed: () {
                  showDateRangePicker(
                    context: context, 
                    firstDate: DateTime(2000), 
                    lastDate: DateTime(2025),
                    initialEntryMode: DatePickerEntryMode.input
                  );
                }, 
                icon: const Icon(Icons.calendar_month))),
    );
  }
}

class TypeDropDown extends StatelessWidget {
  const TypeDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DropdownMenu(
      expandedInsets: EdgeInsets.all(0),
      label: Text('Type'),
      dropdownMenuEntries: <DropdownMenuEntry>[
        DropdownMenuEntry(value: 'All', label: 'All'),
        DropdownMenuEntry(
          value: 'Safety Notice',
          label: 'Safety Notice',
        ),
        DropdownMenuEntry(
          value: 'Hazard Report',
          label: 'Hazard Report',
        ),
        DropdownMenuEntry(
          value: 'Notice to Crew',
          label: 'Notice to Crew',
        ),
        DropdownMenuEntry(
          value: 'BCAA Aircraft Occurrence Report',
          label: 'BCAA Aircraft Occurrence Report',
        )
      ],
    );
  }
}

class ResolvedDropDown extends StatelessWidget {
  const ResolvedDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const DropdownMenu(
      expandedInsets: EdgeInsets.all(0),
      label: Text('Resolved status'),
      dropdownMenuEntries: <DropdownMenuEntry>[
        DropdownMenuEntry(value: 'All', label: 'All'),
        DropdownMenuEntry(
          value: 'Yes',
          label: 'Yes',
        ),
        DropdownMenuEntry(
          value: 'No',
          label: 'No',
        )
      ],
    );
  }
}

class AuthorTextField extends StatelessWidget {
  const AuthorTextField ({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          label: const Text('Author'),
          border: const OutlineInputBorder(),
          suffixIcon:
              IconButton(onPressed: () {}, icon: const Icon(Icons.search))),
    );
  }
}