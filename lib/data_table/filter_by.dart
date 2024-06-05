part of 'abstract_data_table_async.dart';

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

  Widget filterDialog(Map<String, List<String>> filterResult) {
    // list of title of each filter
    List<String> filterTitles = filterEndpoints?.keys.toList() ?? [];
    return FutureBuilder(
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
          Map<String, List<MultiSelectItem>> filterData = snapshot.data!;
          // generate MultiSelectDialogField based on how many filter in filterData
          List<Widget> filterContent = List.generate(
            filterData.length,
            (index) {
              // customise for visual, right now
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: MultiSelectDialogField(
                  // get text based on index
                  buttonText: Text("Filter by ${filterTitles[index]}"),
                  // get list of item from fetchData
                  items: filterData[filterTitles[index]]!,
                  // send selected item to filterResult
                  onConfirm: (selectedOptions) {
                    filterResult[filterTitles[index]] =
                        List<String>.from(selectedOptions);
                  },
                  title: Text("Filter by ${filterTitles[index]}"),
                  searchable: true,
                  // size of dialog after click each filter
                  dialogHeight: 714,
                  dialogWidth: 400,
                  // can be specify based on ThemeData
                  itemsTextStyle: const TextStyle(color: Colors.amber),
                  selectedItemsTextStyle: const TextStyle(color: Colors.blue),
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
                    scrollBar: HorizontalScrollBar(isAlwaysShown: true),
                  ),
                ),
              );
            },
          );
          filterContent.addAll(
            [
              MultiSelectDialogField(
                buttonText: const Text("Filter by archived"),
                items: [
                  MultiSelectItem(true, "True"),
                  MultiSelectItem(false, "False")
                ],
                onConfirm: (selectedOptions) {
                  if (selectedOptions.length != 2) {
                    filterResult["archived"] =
                        List<String>.from(selectedOptions);
                  } else {
                    filterResult["archived"] = [];
                  }
                },
                title: const Text("Filter by archived"),
                initialValue: const [false],
                // size of dialog after click each filter
                dialogHeight: 714,
                dialogWidth: 400,
                // can be specify based on ThemeData
                itemsTextStyle: const TextStyle(color: Colors.amber),
                selectedItemsTextStyle: const TextStyle(color: Colors.blue),
                cancelText: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.amber),
                ),
                confirmText: const Text(
                  "Confirm",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              // Title for choose time range can add style
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Choose a time range"),
              ),
              // Pick time range button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTimeRangePicker(
                  filterResult: filterResult,
                ),
              ),
            ],
          );
          // return column with filter content
          return Container(
            // max width of filter column
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: filterContent,
            ),
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // result of filter before click apply
    Map<String, List<String>> filterResult = {};

    // filter button, the visual can be customised
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Filter By:'),
              content: filterDialog(filterResult),
              actions: [
                // cancel
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                // apply
                TextButton(
                  onPressed: () {
                    filters.filterResult.addAll(filterResult);
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
      child: const Text("Filter By"),
    );
  }
}
