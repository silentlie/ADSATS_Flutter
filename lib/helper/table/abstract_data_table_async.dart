library data_table;

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

part 'filter_by.dart';
part 'filter_class.dart';
part 'cell_function.dart';
part 'search_bar.dart';
part 'time_picker.dart';
part 'sort_by.dart';

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
  // can be customise controller
  final PaginatorController _controller = PaginatorController();
  List<DataColumn> get columns => dataSource.columns;

  @override
  void dispose() {
    // dispose to refresh every time
    // dataSource.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 1536),
      child: AsyncPaginatedDataTable2(
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => colorScheme.surfaceContainerHighest),
        columnSpacing: 5,
        columns: columns,
        source: dataSource,
        empty: const Placeholder(),
        // errorBuilder: (error) => const Placeholder(),
        initialFirstRowIndex: 0,
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
        horizontalMargin: 10,
        checkboxHorizontalMargin: 12,
        checkboxAlignment: Alignment.center,
        dataRowHeight: 62,
        showCheckboxColumn: false,
        // dynamic change rows per page based on height of screen
        autoRowsToHeight: false,
        // how page handle when page go beyond total records
        pageSyncApproach: PageSyncApproach.goToLast,
        minWidth: 1320,
        // stick paginator to the bottom when there's few rows
        fit: FlexFit.loose,
        // render empty rows to match rows per page
        renderEmptyRowsInTheEnd: false,
        // customise border of table
        border: const TableBorder(),
        controller: _controller,
        hidePaginator: false,
        wrapInCard: true,
      ),
    );
  }
}

abstract class DataTableSourceAsync extends AsyncDataTableSource {
  // TODO: need implement error handling
  List<String> get columnNames;
  List<DataColumn> get columns {
    return List.generate(
      columnNames.length,
      (index) {
        String columnName = columnNames[index];
        return DataColumn(
            label: Center(
              child: Text(
                columnName,
              ),
            ),
            tooltip: columnName);
      },
    );
  }

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
