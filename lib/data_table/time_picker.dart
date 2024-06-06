part of 'abstract_data_table_async.dart';

class MutableDateTimeRange {
  // this class was created because DateTimeRange is immutable class
  MutableDateTimeRange([this.dateTimeRange]);
  DateTimeRange? dateTimeRange;
}

class DateTimeRangePicker extends StatefulWidget {
  const DateTimeRangePicker({super.key, required this.filterResult});
  final Map<String, List<String>> filterResult;

  @override
  State<DateTimeRangePicker> createState() => _DateTimeRangePickerState();
}

class _DateTimeRangePickerState extends State<DateTimeRangePicker> {
  DateTimeRange? _dateTimeRange;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
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
                      const BoxConstraints(maxWidth: 800, maxHeight: 800),
                  child: child,
                )
              ],
            );
          },
        );
        if (_dateTimeRange != null) {
          widget.filterResult["create_at"] = [
            _dateTimeRange!.start.toIso8601String(),
            _dateTimeRange!.end.toIso8601String()
          ];
        }
        setState(() {});
      },
      child: Text(
        _dateTimeRange == null
            ? "Select a date range"
            // need to modify for readable string
            : "${_dateTimeRange!.start.toIso8601String()} - ${_dateTimeRange!.end.toIso8601String()}",
      ),
    );
  }
}
