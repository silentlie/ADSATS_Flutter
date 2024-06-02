import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

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

  @override
  List<DataColumn> get columns {
    return <DataColumn>[
      const DataColumn(
        label: Text("First Name"),
        tooltip: "First Name",
      ),
      const DataColumn(
        label: Text("Last Name"),
        tooltip: "Last Name",
      ),
      const DataColumn(
        label: Text("Email"),
        tooltip: "Email",
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
        label: Text("Roles"),
        tooltip: "Roles",
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

  Map<String, String> get filterEndpoints => {};

  @override
  Widget get header => Row(
        children: [
          const Text(
            "Documents",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const AddNewStaff(),
          const Spacer(),
          SearchBarWidget(
            filters: filters,
            refreshDatasource: refreshDatasource,
          ),
          const SizedBox(
            width: 10,
          ),
          FilterBy(
            filters: filters,
            refreshDatasource: refreshDatasource,
            filterEndpoints: filterEndpoints,
          ),
        ],
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
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black),
          ),
        ),
      ),
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
