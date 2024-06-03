import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

class Aircraft {
  Aircraft(
      {required int id,
      required String name,
      required bool archived,
      required DateTime createdAt,
      DateTime? modifiedAt})
      : _id = id,
        _name = name,
        _archived = archived,
        _createdAt = createdAt;
  final int _id;
  final String _name;
  final bool _archived;
  final DateTime _createdAt;
  int get id => _id;
  String get name => _name;
  bool get archived => _archived;
  DateTime get createdAt => _createdAt;

  Aircraft.fromJSON(Map<String, dynamic> json)
      : _id = json["aircraft_id"] as int,
        _name = json["name"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _createdAt = DateTime.parse(json["created_at"]);

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(cells: <DataCell>[
      cellFor(name),
      cellFor(archived),
      cellFor(createdAt),
      cellFor("actions"),
    ]);
  }
}

class AircraftsAPI extends DataTableSourceAsync {
  AircraftsAPI();

  @override
  get showCheckBox => false;

  @override
  List<DataColumn> get columns {
    return <DataColumn>[
      const DataColumn(
        label: Text("Name"),
        tooltip: "Name of the Aircraft",
      ),
      const DataColumn(
        label: Text("Archived"),
        tooltip: "Archived",
      ),
      const DataColumn(
        label: Text("Created At"),
        tooltip: "Created At",
      ),
      const DataColumn(
        label: Text("Actions"),
        tooltip: "Actions",
      ),
    ];
  }

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Aircraft> _aircrafts = [];
  int _totalRecords = 0;
  @override
  int get totalRecords => _totalRecords;

  @override
  Future<void> fetchData(
      int startIndex, int count, CustomTableFilter filter) async {
    try {
      Map<String, String> queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
      queryParameters.addAll(filter.toJSON());
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/aircrafts',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _aircrafts = [for (var row in rowsData) Aircraft.fromJSON(row)];
      debugPrint(_aircrafts.length.toString());
      debugPrint("finished fetch table data");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _aircrafts.map((notice) {
      return notice.toDataRow();
    }).toList();
  }

  Map<String, String> get filterEndpoints => {};

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Aircrafts",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 5),
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: [
              const AddNewAircraft(),
              const SizedBox(
                width: 10,
              ),
              FilterBy(
                filters: filters,
                refreshDatasource: refreshDatasource,
                filterEndpoints: filterEndpoints,
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement Sort By function
                },
                child: const Text("Sort By"),
              ),
              const SizedBox(
                width: 10,
              ),
              SearchBarWidget(
                filters: filters,
                refreshDatasource: refreshDatasource,
              ),
            ],
          ),
        ),
      );
}

class AddNewAircraft extends StatelessWidget {
  const AddNewAircraft({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // context.go('/');
      },
      // testing visual
      // style: ButtonStyle(
      //   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      //     RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //       side: const BorderSide(color: Colors.black),
      //     ),
      //   ),
      // ),
      child: const Row(
        children: [
          Icon(
            Icons.add,
            size: 30,
          ),
          SizedBox(width: 5),
          Text(
            'Add new aircraft',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
