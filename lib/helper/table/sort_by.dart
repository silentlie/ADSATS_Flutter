part of 'abstract_data_table_async.dart';

class SortBy extends StatelessWidget {
  const SortBy({
    super.key,
    required this.filters,
    required this.refreshDatasource,
    required this.sqlColumns,
  });
  final CustomTableFilter filters;
  final Function refreshDatasource;
  final Map<String, String> sqlColumns;
  @override
  Widget build(BuildContext context) {
    // result of filter before click apply
    Map<String, dynamic> tempResult = {};
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sort By:'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu(
                      dropdownMenuEntries: sqlColumns.entries.map(
                        (e) {
                          return DropdownMenuEntry(
                              value: e.value, label: e.key);
                        },
                      ).toList(),
                      enableFilter: true,
                      hintText: "Select a column to sort",
                      label: const Text(
                        "Select a column to sort",
                      ),
                      onSelected: (value) {
                        if (value == null) {
                          return;
                        }
                        tempResult['sort_column'] = value;
                      },
                      initialSelection: filters.filterResults['sort_column'],
                      requestFocusOnTap: false,
                      expandedInsets: EdgeInsets.zero,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownMenu(
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: true, label: "ASC"),
                        DropdownMenuEntry(value: false, label: "DESC")
                      ],
                      hintText: "ASC or DESC",
                      label: const Text("ASC or DESC"),
                      initialSelection: filters.filterResults['asc'],
                      onSelected: (value) {
                        tempResult['asc'] = value;
                      },
                      requestFocusOnTap: false,
                      expandedInsets: EdgeInsets.zero,
                    ),
                  ),
                ],
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
                    filters.filterResults.addAll(tempResult);
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
      child: const Text("Sort by"),
    );
  }
}
