import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'package:flutter/material.dart';

class FilterBy extends StatefulWidget {
  const FilterBy(
      {super.key, required this.filter, required this.refreshDatasource});
  final CustomTableFilter filter;
  final Function refreshDatasource;
  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  final MutableDateTimeRange _timeRange = MutableDateTimeRange();
  List<Widget> get filterContent {
    return <Widget>[
      DateTimeRangePicker(
        mutableDateTimeRange: _timeRange,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Filter By:'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: filterContent,
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        widget.refreshDatasource();
                        Navigator.pop(context, 'Apply');
                      },
                      child: const Text('Apply'))
                ],
              );
            }),
        child: const Text("Filter By"));
  }
}
