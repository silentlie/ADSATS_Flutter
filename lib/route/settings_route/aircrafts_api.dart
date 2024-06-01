import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'search_widget.dart';

class AircraftsAPI extends DataTableSourceAsync {
  AircraftsAPI();
  @override
  get showCheckBox => false;
  CustomTableFilter? _filters;

  @override
  List<DataColumn> get columns {
    return <DataColumn>[
      const DataColumn(
        label: Text("Name"),
        tooltip: "Name of the Aircraft",
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
    return aircrafts.map(
      (row) {
        return DataRow(cells: <DataCell>[
          cellFor(row.name),
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
    return aircrafts.length;
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
        'Aircrafts',
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

class Aircraft {
  Aircraft(this._id, this._name, this._status, this._createdAt,
      {DateTime? modifiedAt})
      : _modifiedAt = modifiedAt;
  final int _id;
  final String _name;
  final bool _status;
  final DateTime _createdAt;
  final DateTime? _modifiedAt;
  int get id => _id;
  String get name => _name;
  bool get status => _status;
  DateTime get createdAt => _createdAt;
  DateTime? get modifiedAt => _modifiedAt;
}

List<Aircraft> aircrafts = [
  Aircraft(0, "VQ-BOS", true, DateTime.now()),
  Aircraft(0, "VP-BLU", false, DateTime.now(), modifiedAt: DateTime.now()),
];

List<Map<String, String>> planeData = [
  {'name': 'Plane 1', 'description': 'Description of Plane 1'},
  {'name': 'Plane 2', 'description': 'Description of Plane 2'},
  {'name': 'Plane 3', 'description': 'Description of Plane 3'},
];

