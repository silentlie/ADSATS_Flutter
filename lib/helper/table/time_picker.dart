part of 'abstract_data_table_async.dart';

class DateTimeRangePicker extends StatefulWidget {
  const DateTimeRangePicker({super.key, required this.filterResult});
  final Map<String, dynamic> filterResult;

  @override
  State<DateTimeRangePicker> createState() => _DateTimeRangePickerState();
}

class _DateTimeRangePickerState extends State<DateTimeRangePicker> {
  DateTimeRange? _dateTimeRange;
  @override
  Widget build(BuildContext context) {
    if (widget.filterResult['created_at'] is DateTimeRange?) {
      _dateTimeRange = widget.filterResult['created_at'];
    }
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
                      const BoxConstraints(maxWidth: 500, maxHeight: 550),
                  child: child,
                )
              ],
            );
          },
        );
        if (_dateTimeRange != null) {
          widget.filterResult["create_at"] = _dateTimeRange;
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
