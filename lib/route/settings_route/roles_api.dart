import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

class Role {
  Role(
      {required int id,
      required String name,
      required bool archived,
      required String description})
      : _id = id,
        _name = name,
        _archived = archived,
        _description = description;
  final int _id;
  final String _name;
  final bool _archived;
  final String _description;
  int get id => _id;
  String get name => _name;
  bool get archived => _archived;
  String get description => _description;

  Role.fromJSON(Map<String, dynamic> json)
      : _id = json["role_id"] as int,
        _name = json["role"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _description = json["description"] as String;

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
      cellFor(description),
      cellFor("actions"),
    ]);
  }
}

class RolesAPI extends DataTableSourceAsync {
  RolesAPI();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "Name",
        "Archived",
        "Description",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Role> _roles = [];
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
      final restOperation = Amplify.API.get('/roles',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _roles = [for (var row in rowsData) Role.fromJSON(row)];
      debugPrint(_roles.length.toString());
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
    return _roles.map((notice) {
      return notice.toDataRow();
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'Role': 'role',
        'Archived': "archived",
        'Description': 'description',
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Roles",
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
              const AddNewRole(),
              const SizedBox(
                width: 10,
              ),
              const SizedBox(
                width: 10,
              ),
              FilterBy(
                filters: filters,
                refreshDatasource: refreshDatasource,
              ),
              const SizedBox(
                width: 10,
              ),
              SortBy(
                  filters: filters,
                  refreshDatasource: refreshDatasource,
                  sqlColumns: sqlColumns),
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

class AddNewRole extends StatelessWidget {
  const AddNewRole({super.key});

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
            'Add new role',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
