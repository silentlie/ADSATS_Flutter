import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

class FilterBy extends StatefulWidget {
  const FilterBy(
      {super.key, required this.filter, required this.refreshDatasource});
  final CustomTableFilter filter;
  final Function refreshDatasource;
  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  Future<List<List<MultiSelectItem>>> fetchFilter() async {
    try {
      // Function to make API requests and return the parsed response
      Future<List<String>> fetchData(String endpoint) async {
        RestOperation restOperation =
            Amplify.API.get(endpoint, apiName: 'AmplifyCrewAPI');
        AWSHttpResponse response = await restOperation.response;
        String jsonStr = response.decodeBody();
        // Map<String, dynamic> rawData = jsonDecode(jsonStr);
        return List<String>.from(jsonDecode(jsonStr));
      }

      // Perform all fetches concurrently
      List<Future<List<String>>> futures = [
        fetchData('/crews'),
        fetchData('/roles'),
        fetchData('/aircrafts'),
        fetchData('/document-categories'),
        fetchData('/document-sub-categories'),
      ];

      List<List<String>> results = await Future.wait(futures);
      // Function to map List<String> to List<ValueItem>
      List<MultiSelectItem> mapToValueItemList(List<String> list) {
        return list.map((item) => MultiSelectItem(item, item)).toList();
      }

      // Process the results
      safePrint("did fetch Filter");
      return results.map(mapToValueItemList).toList();
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  final MutableDateTimeRange _timeRange = MutableDateTimeRange();
  List<List<String>> filterResult = [];
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Filter By:'),
                content: FutureBuilder(
                  future: fetchFilter(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      List<List<MultiSelectItem>> filterData = snapshot.data!;
                      filterResult =
                          List.generate(filterData.length, (index) => []);
                      List<Widget> filterContent = List.generate(
                        filterData.length,
                        (index) {
                          return MultiSelectDialogField(
                            items: filterData[index],
                            onConfirm: (selectedOptions) {
                              filterResult[index] =
                                  List<String>.from(selectedOptions);
                            },
                            searchable: true,
                            dialogHeight: 200,
                            dialogWidth: 400,
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
                          );
                        },
                      );
                      filterContent.add(DateTimeRangePicker(
                        mutableDateTimeRange: _timeRange,
                      ));

                      return Container(
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
            },
          );
        },
        child: const Text("Filter By"));
  }
}
