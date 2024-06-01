import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'search_widget.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

class CrewsApi extends DataTableSourceAsync {
  CrewsApi();
  @override
  get showCheckBox => false;
  CustomTableFilter? _filters;
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
        label: Text("Role"),
        tooltip: "Role",
      ),
      const DataColumn(
        label: Text("Active"),
        tooltip: "Active",
      ),
      const DataColumn(
        label: Text("Created At"),
        tooltip: "Created At",
      ),
      const DataColumn(
        label: Text("Modified At"),
        tooltip: "Modified At",
      ),
    ];
  }

  List<DataRow> get rows {
    return crews.map(
      (row) {
        return DataRow(cells: <DataCell>[
          cellFor(row.firstName),
          cellFor(row.lastName),
          cellFor(row.email),
          cellFor(row.roles),
          cellFor(row.status),
          cellFor(row.createdAt),
          cellFor(row.modifiedAt),
        ]);
      },
    ).toList();
  }

  Future<void> fetchData(int startIndex, int count,
      [CustomTableFilter? filter]) async {
    // TODO: implement getData one API finish
  }
  @override
  int get totalRecords {
    // TODO: implement get totalRecords once API finish
    return crews.length;
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    // implement filtering
    await fetchData(startIndex, count, _filters);
    AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
    return response;
  }

  final Widget _header = Row(
    children: [
      const Text(
        'Crews',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      const AddNewCrewButton(),
      const Spacer(),
      // TODO: implement search function
      SearchWidget(),
      const SizedBox(
        width: 10,
      ),
      ElevatedButton(
        onPressed: () {
          // TODO: implement filter function
        },
        child: const Text("Filter By"),
      ),
    ],
  );
  @override
  Widget get header => _header;
}

class AddNewCrewButton extends StatelessWidget {
  const AddNewCrewButton({super.key});

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

class Crew {
  Crew(this._id, this._firstName, this._lastName, this._email, this._status,
      this._createdAt, this._roles,
      {DateTime? modifiedAt})
      : _modifiedAt = modifiedAt;
  final int _id;
  final String _firstName;
  final String _lastName;
  final String _email;
  final bool _status;
  final DateTime _createdAt;
  final DateTime? _modifiedAt;
  final List<String> _roles;
  int get id => _id;
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  bool get status => _status;
  DateTime get createdAt => _createdAt;
  DateTime? get modifiedAt => _modifiedAt;
  List<String> get roles => _roles;
}

List<Crew> crews = [
  Crew(0, "John", "Doe", "john@example.com", true, DateTime.now(), ["Admin"]),
  Crew(1, "Jane", "Smith", "jane@example.com", false, DateTime.now(), ["Crew"],
      modifiedAt: DateTime.now()),
  Crew(1, "Bob", "Johnson", "bob@example.com", false, DateTime.now(),
      ["Manager"],
      modifiedAt: DateTime.now()),
];
