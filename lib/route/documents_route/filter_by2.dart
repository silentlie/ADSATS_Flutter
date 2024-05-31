import 'dart:convert';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class FilterBy extends StatefulWidget {
  const FilterBy(
      {super.key, required this.filter, required this.refreshDatasource});
  final CustomTableFilter filter;
  final Function refreshDatasource;
  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  Future<List<List<ValueItem>>> fetchFilter() async {
    try {
      // Function to make API requests and return the parsed response
      Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
        var restOperation =
            Amplify.API.get(endpoint, apiName: 'AmplifyCrewAPI');
        var response = await restOperation.response;
        String jsonStr = response.decodeBody();
        Map<String, dynamic> rawData = jsonDecode(jsonStr);
        return List<Map<String, dynamic>>.from(rawData["rows"]);
      }

      // Perform all fetches concurrently
      List<Future<List<Map<String, dynamic>>>> futures = [
        fetchData('/crews'),
        fetchData('/roles'),
        fetchData('/aircrafts'),
        fetchData('/categories'),
        fetchData('/sub-categories'),
      ];

      List<List<Map<String, dynamic>>> results = await Future.wait(futures);

      // Process the results
      List<ValueItem> emails = results[0]
          .map((row) => ValueItem(label: row["email"], value: row["email"]))
          .toList();
      List<ValueItem> roles = results[1]
          .map((row) => ValueItem(label: row["role"], value: row["role"]))
          .toList();
      List<ValueItem> aircrafts = results[2]
          .map((row) => ValueItem(label: row["name"], value: row["name"]))
          .toList();
      List<ValueItem> categories = results[3]
          .map((row) => ValueItem(label: row["name"], value: row["name"]))
          .toList();
      List<ValueItem> subCategories = results[4]
          .map((row) => ValueItem(label: row["name"], value: row["name"]))
          .toList();

      safePrint("did fetch Filter");
      return [emails, roles, aircrafts, categories, subCategories];
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  final MutableDateTimeRange _timeRange = MutableDateTimeRange();
  Future<Widget> filterContent(List<List<ValueItem>> filterResult) async {
    List<List<ValueItem>> filterData = await fetchFilter();
    filterResult = List.generate(filterData.length, (index) => []);
    List<Widget> filterContent = List.generate(
      filterData.length,
      (index) {
        return MultiSelectDropDown(
            onOptionSelected: (selectedOptions) {
              filterResult[index] = selectedOptions;
            },
            options: filterData[index]);
      },
    );
    filterContent.add(DateTimeRangePicker(
      mutableDateTimeRange: _timeRange,
    ));
    Column filterColumn = Column(
      children: filterContent,
    );
    return filterColumn;
  }

  @override
  Widget build(BuildContext context) {
    List<List<ValueItem>> filterResult = [];
    return ElevatedButton(
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Filter By:'),
                content: FutureBuilder(
                  future: filterContent(filterResult),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.requireData;
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
            }),
        child: const Text("Filter By"));
  }
}
