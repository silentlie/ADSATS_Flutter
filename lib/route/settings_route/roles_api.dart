import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'search_widget.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

class RolesAPI extends DataTableSourceAsync {
  RolesAPI();
  @override
  get showCheckBox => false;
  CustomTableFilter? _filters;
  @override
  CustomTableFilter? get filters => _filters;
  @override
  set filters(CustomTableFilter? newFilters) {
    filters = newFilters;
    refreshDatasource();
  }
  @override
  List<DataColumn> get columns{
    return <DataColumn>[
      const DataColumn(label: Text("Name"), tooltip: "Name of the role",),
      const DataColumn(label: Text("Description"), tooltip: "Brief description about the role",),
    ];
  }
  List<DataRow> get rows {
    return roles.map(
      (row) {
        return DataRow(cells: <DataCell>[
          cellFor(row.name),
          cellFor(row.description),
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
    return roles.length;
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    // implement filtering
    await fetchData(startIndex, count, filters);
    AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
    return response;
  }

  final Widget _header = Row(
    children: [
      const Text(
        'Roles',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(width: 10,),
      const AddNewCrewButton(),
      const Spacer(),
      // TODO: implement search function
      SearchWidget(),
    const SizedBox(width: 10,),
    ElevatedButton(onPressed: () {
      // TODO: implement filter function
    }, child: const Text("Filter By"),),
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

class Role {
  Role(this._id, this._name, this._description,);
  final int _id;
  final String _name;
  final String _description;
  int get id => _id;
  String get name => _name;
  String get description => _description;
}

List<Role> roles = [
  Role(0, "Admin", "Administrator role"),
  Role(1, "Crew", "Regular crew role"),
  Role(2, "Manager", "Manager role"),
];
