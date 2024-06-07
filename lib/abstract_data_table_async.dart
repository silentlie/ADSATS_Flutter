import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class PaginatedDataTableAsync extends StatefulWidget {
  const PaginatedDataTableAsync(this._dataSource, {super.key});
  final DataTableSourceAsync _dataSource;
  @override
  State<PaginatedDataTableAsync> createState() =>
      _PaginatedDataTableAsyncState();
}

class _PaginatedDataTableAsyncState extends State<PaginatedDataTableAsync> {
  DataTableSourceAsync get dataSource => widget._dataSource;
  // default is 10
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _initialRow = 0;
  // can be customise controller
  final PaginatorController _controller = PaginatorController();
  List<DataColumn> get columns => dataSource.columns;

  @override
  void didChangeDependencies() {
    // need to check _dataSource has changed based on filter
    debugPrint("didChangeDependencies");
    setState(
      () {
        _initialRow = 0;
      },
    );

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // dispose to refresh every time
    // dataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AsyncPaginatedDataTable2(
      headingRowColor: WidgetStateColor.resolveWith(
          (states) => colorScheme.surfaceContainerHighest),
      columnSpacing: 0,
      columns: columns,
      source: dataSource,
      empty: const Placeholder(),
      errorBuilder: (error) => const Placeholder(),
      initialFirstRowIndex: _initialRow,
      rowsPerPage: _rowsPerPage,
      availableRowsPerPage: [
        _rowsPerPage,
        _rowsPerPage * 2,
        _rowsPerPage * 5,
        _rowsPerPage * 10,
      ],
      onRowsPerPageChanged: (value) {
        // No need to wrap in setState, behave diff in this package
        _rowsPerPage = value!;
      },
      onPageChanged: (rowIndex) {
        debugPrint((rowIndex / _rowsPerPage).toString());
      },
      // can add more widget if need
      header: dataSource.header,

      actions: const [],
      horizontalMargin: 20,
      checkboxHorizontalMargin: 12,
      checkboxAlignment: Alignment.center,
      showCheckboxColumn: false,
      // dynamic change rows per page based on height of screen
      autoRowsToHeight: false,
      // how page handle when page go beyond total records
      pageSyncApproach: PageSyncApproach.goToLast,
      minWidth: 950,
      // stick paginator to the bottom when there's few rows
      fit: FlexFit.loose,
      // render empty rows to match rows per page
      renderEmptyRowsInTheEnd: false,
      // customise border of table
      border: const TableBorder(),
      controller: _controller,
      hidePaginator: false,
      wrapInCard: true,
    );
  }
}

abstract class DataTableSourceAsync extends AsyncDataTableSource {
  // TODO: need implement error handling
  List<DataColumn> get columns;
  bool get showCheckBox;
  int get totalRecords;
  Widget get header;
  List<DataRow> get rows;
  CustomTableFilter get filters;
  Future<void> fetchData(int startIndex, int count, CustomTableFilter filter);
  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    try {
      // implement filtering
      await fetchData(startIndex, count, filters);
      AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
      return response;
    } on Error catch (e) {
      safePrint('Error: $e');
      rethrow;
    }
  }
}

class CustomTableFilter {
  String? sortColumn;
  bool sortAscending = true;

  String? search;
  bool? archived = false;

  DateTimeRange? createdTimeRange;
  DateTimeRange? dueTimeRange;

  Map<String, List<String>> filterResult = {};

  CustomTableFilter({
    this.sortColumn,
    this.sortAscending = true,
    this.archived = false,
    this.createdTimeRange,
  });
  Map<String, String> toJSON() {
    Map<String, String> tempJson = {};
    if (search != null) {
      tempJson["search"] = "%${search!}%";
    }
    if (sortColumn != null) {
      tempJson["sort_column"] = sortColumn!;
      tempJson["asc"] = sortAscending.toString();
    }
    if (createdTimeRange != null) {
      tempJson["create_at"] =
          "${createdTimeRange!.start.toIso8601String()},${createdTimeRange!.end.toIso8601String()}";
    }
    if (filterResult.isNotEmpty) {
      tempJson.addAll(
        filterResult.map(
          (key, value) {
            return MapEntry(
              key,
              value.join(','),
            );
          },
        ),
      );
    }
    tempJson["archived"] = archived.toString();
    return tempJson;
  }
}

class MutableDateTimeRange {
  // this class was created because DateTimeRange is immutable class
  MutableDateTimeRange([this.dateTimeRange]);
  DateTimeRange? dateTimeRange;
}

class DateTimeRangePicker extends StatefulWidget {
  const DateTimeRangePicker({super.key, required this.mutableDateTimeRange});
  final MutableDateTimeRange mutableDateTimeRange;

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
          widget.mutableDateTimeRange.dateTimeRange = _dateTimeRange;
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

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget(
      {super.key, required this.filters, required this.refreshDatasource});
  final CustomTableFilter filters;
  final Function refreshDatasource;
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _textEditingController.text = widget.filters.search ?? '';
    return SearchBar(
      elevation: const WidgetStatePropertyAll(1),
      constraints: const BoxConstraints(
        minHeight: 32,
        maxWidth: 200,
      ),
      controller: _textEditingController,
      onSubmitted: (value) {
        widget.filters.search = value;
        widget.refreshDatasource();
      },
      trailing: const [Icon(Icons.search)],
    );
  }
}

DataCell cellFor(Object? data) {
  Widget widget = const Text("");
  if (data == null) {
    widget = const Text("");
  } else if (data is DateTime) {
    widget = Text(
        '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}');
  } else if (data is bool) {
    widget = Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        color: data ? Colors.green : Colors.red,
      ),
      child: Center(child: Text(data ? "Yes" : "No")),
    );
  }
  // need to fix
  else if (data is List<String>) {
    widget = Row(
        children: data.map(
      (string) {
        return Text(string);
      },
    ).toList());
  } else {
    widget = Text(data.toString());
  }
  return DataCell(widget);
}

class FilterBy extends StatelessWidget {
  const FilterBy(
      {super.key,
      required this.filters,
      required this.refreshDatasource,
      this.filterEndpoints});
  final CustomTableFilter filters;
  final Function refreshDatasource;
  final Map<String, String>? filterEndpoints;
  Future<Map<String, List<MultiSelectItem>>> fetchFilter(
      Map<String, String>? filterEndpoints) async {
    try {
      // Function to make API requests and return the parsed response
      Future<List<String>> fetchData(String endpoint) async {
        RestOperation restOperation =
            Amplify.API.get(endpoint, apiName: 'AmplifyFilterAPI');
        AWSHttpResponse response = await restOperation.response;
        String jsonStr = response.decodeBody();
        // Map<String, dynamic> rawData = jsonDecode(jsonStr);
        return List<String>.from(jsonDecode(jsonStr));
      }

      // Perform all fetches concurrently
      List<Future<List<String>>> futures =
          filterEndpoints?.values.map(fetchData).toList() ?? [];

      List<List<String>> results = await Future.wait(futures);
      // Function to map List<String> to List<ValueItem>
      List<MultiSelectItem> mapToValueItemList(List<String> list) {
        return list.map((item) => MultiSelectItem(item, item)).toList();
      }

      List<String> keys = filterEndpoints?.keys.toList() ?? [];
      List<List<MultiSelectItem>> values =
          results.map(mapToValueItemList).toList();
      Map<String, List<MultiSelectItem>> mappedResults =
          Map.fromIterables(keys, values);
      // Process the results
      safePrint("did fetch Filter");
      return mappedResults;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // time range for filter
    final MutableDateTimeRange timeRange = MutableDateTimeRange();
    // result of filter before click apply
    Map<String, List<String>> filterResult = {};
    // list of title of each filter
    List<String> filterTitles = filterEndpoints?.keys.toList() ?? [];
    // filter button, the visual can be customised
    return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Filter By:'),
                content: FutureBuilder(
                  future: fetchFilter(filterEndpoints),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // loading widget can be customise
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // can make it into a error widget for more visualise
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      // if data is fetch successfully
                      Map<String, List<MultiSelectItem>> filterData =
                          snapshot.data!;
                      // generate MultiSelectDialogField based on how many filter in filterData
                      List<Widget> filterContent = List.generate(
                        filterData.length,
                        (index) {
                          // customise for visual, right now
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MultiSelectDialogField(
                              // get text based on index
                              buttonText:
                                  Text("Filter by ${filterTitles[index]}"),
                              // get list of item from fetchData
                              items: filterData[filterTitles[index]]!,
                              // send selected item to filterResult
                              onConfirm: (selectedOptions) {
                                filterResult[filterTitles[index]] =
                                    List<String>.from(selectedOptions);
                              },
                              searchable: true,
                              // size of dialog after click each filter
                              dialogHeight: 200,
                              dialogWidth: 400,
                              // can be specify based on ThemeData
                              itemsTextStyle:
                                  const TextStyle(color: Colors.amber),
                              selectedItemsTextStyle:
                                  const TextStyle(color: Colors.blue),
                              cancelText: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.amber),
                              ),
                              confirmText: const Text(
                                "Confirm",
                                style: TextStyle(color: Colors.blue),
                              ),
                              chipDisplay: MultiSelectChipDisplay(
                                scroll: true,
                                scrollBar:
                                    HorizontalScrollBar(isAlwaysShown: true),
                              ),
                            ),
                          );
                        },
                      );
                      filterContent.addAll([
                        // Title for choose time range can add style
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("Choose a time range"),
                        ),
                        // Pick time range button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DateTimeRangePicker(
                            mutableDateTimeRange: timeRange,
                          ),
                        ),
                      ]);
                      // return column with filter content
                      return Container(
                        // max width of filter column
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filterContent,
                        ),
                      );
                    } else {
                      return const Placeholder();
                    }
                  },
                ),
                actions: [
                  // cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  // apply
                  TextButton(
                    onPressed: () {
                      filters.filterResult = filterResult;
                      // apply time range to filter
                      filters.createdTimeRange = timeRange.dateTimeRange;
                      // refresh table based on filter
                      refreshDatasource();
                      Navigator.pop(context, 'Apply');
                    },
                    child: const Text('Apply'),
                  )
                ],
              );
            },
          );
        },
        child: const Text("Filter By"));
  }
}

