import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

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
    safePrint("didChangeDependencies");
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
        safePrint(rowIndex / _rowsPerPage);
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

  bool intToBool(int value) {
    return value != 0;
  }
}

class CustomTableFilter {
  String? sortColumn;
  bool sortAscending = true;

  String? search;
  bool? status;

  DateTimeRange? createdTimeRange;
  DateTimeRange? dueTimeRange;
  CustomTableFilter.empty() : sortAscending = true;
  CustomTableFilter({
    this.sortColumn,
    this.sortAscending = true,
    this.createdTimeRange,
  });
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> tempJson = {};
    if (search != null) {
      tempJson["search"] = "%25${search!}%25";
    }
    if (sortColumn != null) {
      tempJson["sort_column"] = sortColumn!;
      tempJson["asc"] = sortAscending;
    }
    if (status != null) {
      tempJson["status"] = status;
    }
    return tempJson;
  }
}

class MutableDateTimeRange {
  // this class was created because DateTimeRange is immutable class
  MutableDateTimeRange([this.dateTimeRange]);
  DateTimeRange? dateTimeRange;
}
