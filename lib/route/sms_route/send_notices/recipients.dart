import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class RecepientsWidget extends StatelessWidget {
  const RecepientsWidget({super.key});

  static Map<String, List<String>> recipientsResult = {};

  static Map<String, String> filterEndpoints = {
    'recepients': '/staff',
    'roles': '/roles',
    'aircrafts': '/aircrafts',
  };

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
    // list of title of each filter
    List<String> filterTitles = filterEndpoints.keys.toList();
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
              return Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: MultiSelectDialogField(
                    autovalidateMode: AutovalidateMode.always,
                    // get text based on index
                    buttonText: Text("Filter by ${filterTitles[index]}"),
                    // get list of item from fetchData
                    items: filterData[filterTitles[index]]!,
                    // send selected item to filterResult
                    onConfirm: (selectedOptions) {
                      recipientsResult[filterTitles[index]] =
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
                ),
              );
            },
          );
          // return column with filter content
          return Row(
            children: filterContent,
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
