import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

part 'roles_api.dart';

class Role {
  Role({
    required int id,
    required String name,
    required bool archived,
    required String? description,
    required DateTime? createdAt,
  })  : _id = id,
        _name = name,
        _archived = archived,
        _description = description,
        _createdAt = createdAt;
  final int _id;
  final String _name;
  bool _archived;
  final String? _description;
  final DateTime? _createdAt;
  int get id => _id;
  String get name => _name;
  bool get archived => _archived;
  String? get description => _description;
  DateTime? get createdAt => _createdAt;

  Role.fromJSON(Map<String, dynamic> json)
      : _id = json["role_id"] as int,
        _name = json["role"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _description = json["description"] as String?,
        _createdAt = json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null;

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(
      cells: <DataCell>[
        cellFor(name),
        cellFor(archived),
        cellFor(description),
        cellFor(createdAt),
        DataCell(
          Builder(builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IconButton(
                //     onPressed: () {},
                //     icon: const Icon(Icons.remove_red_eye_outlined)),
                IconButton(
                    onPressed: () {
                      changeDetails(context);
                    },
                    icon: const Icon(Icons.edit_outlined)),
                IconButton(
                    onPressed: () {
                      archive();
                    },
                    icon: const Icon(Icons.archive_outlined)),
                IconButton(
                    onPressed: () {
                      delete();
                    },
                    icon: const Icon(Icons.delete_outline)),
              ],
            );
          }),
        ),
      ],
    );
  }

  void changeDetails(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String roleName = '';
    String description = '';
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change role details"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Role Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter role name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          roleName = value!;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          description = value!;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context, 'Cancel');
                  },
                  label: const Text('Cancel'),
                  icon: Icon(
                    Icons.cancel,
                    color: colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      changeRoleDetails(roleName, description);
                      Navigator.pop(context, 'Submit');
                    }
                  },
                  style: ButtonStyle(
                    // Change button background color
                    backgroundColor:
                        WidgetStateProperty.all<Color>(colorScheme.secondary),
                  ),
                  label: Text(
                    'Edit this role',
                    style: TextStyle(color: colorScheme.onSecondary),
                  ),
                  icon: Icon(
                    Icons.mail,
                    color: colorScheme.onSecondary,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> changeRoleDetails(String name, String description) async {
    try {
      Map<String, dynamic> body = {
        "role_id": _id,
        "role": name,
        "description": description
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/roles',
          apiName: 'AmplifyAdminAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      debugPrint(rawData.toString());
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> archive() async {
    try {
      Map<String, dynamic> body = {
        'archived': !_archived,
        'role_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/roles',
          apiName: 'AmplifyAdminAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      _archived = !_archived;
      debugPrint("archive: $rawData");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      Map<String, dynamic> body = {
        'role_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/roles',
          apiName: 'AmplifyAdminAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      debugPrint("delete: $rawData");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
