import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

class Staff {
  Staff({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required bool archived,
    required DateTime createdAt,
    String? roles,
  })  : _id = id,
        _firstName = firstName,
        _lastName = lastName,
        _email = email,
        _archived = archived,
        _createdAt = createdAt,
        _roles = roles;
  final int _id;
  final String _firstName;
  final String _lastName;
  final String _email;
  final bool _archived;
  final DateTime _createdAt;
  final String? _roles;
  int get id => _id;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  bool get archived => _archived;
  DateTime get createdAt => _createdAt;
  String? get roles => _roles;

  Staff.fromJSON(Map<String, dynamic> json)
      : _id = json["staff_id"] as int,
        _firstName = json["f_name"] as String,
        _lastName = json["l_name"] as String,
        _email = json["email"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _createdAt = DateTime.parse(json["created_at"]),
        _roles = json["l_name"] as String;

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(cells: <DataCell>[
      cellFor(firstName),
      cellFor(lastName),
      cellFor(email),
      cellFor(archived),
      cellFor(createdAt),
      cellFor(roles),
      cellFor("actions"),
    ]);
  }
}

class StaffApi extends DataTableSourceAsync {
  StaffApi();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "First Name",
        "Last Name",
        "Email",
        "Archived",
        "Created At",
        "Roles",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Staff> _staff = [];
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
      final restOperation = Amplify.API.get('/staff',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _staff = [for (var row in rowsData) Staff.fromJSON(row)];
      debugPrint(_staff.length.toString());
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
    return _staff.map((notice) {
      return notice.toDataRow();
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'First Name': 'f_name',
        'Last Name': 'l_name',
        'Email': 'email',
        'Archived': "archived",
        'Date': 'created_at',
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Staff",
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
              const AddNewStaff(),
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

class AddNewStaff extends StatelessWidget {
  const AddNewStaff({super.key});

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
            'Add new crew',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
