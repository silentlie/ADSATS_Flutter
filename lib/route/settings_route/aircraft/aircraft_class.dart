import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

part 'aircraft_api.dart';

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
  bool _archived;
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
  DataRow toDataRow(void Function() refreshDatasource) {
    return DataRow(
      cells: <DataCell>[
        cellFor(name),
        cellFor(archived),
        cellFor(createdAt),
        DataCell(
          Builder(builder: (context) {
            AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // IconButton(
                //     onPressed: () {},
                //     icon: const Icon(Icons.remove_red_eye_outlined)),
                IconButton(
                    onPressed: () {
                      changeDetails(context);
                      authNotifier.reInitialize();
                      refreshDatasource();
                    },
                    icon: const Icon(Icons.edit_outlined)),
                IconButton(
                    onPressed: () {
                      archive();
                      authNotifier.reInitialize();
                      refreshDatasource();
                    },
                    icon: const Icon(Icons.archive_outlined)),
                IconButton(
                    onPressed: () {
                      delete();
                      authNotifier.reInitialize();
                      refreshDatasource();
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
    String aircraftName = '';
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change aircraft details"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Aircraft Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter aircraft name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          aircraftName = value!;
                        },
                        initialValue: name,
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
                      changeAircraftDetails(aircraftName);
                      Navigator.pop(context, 'Submit');
                    }
                  },
                  style: ButtonStyle(
                    // Change button background color
                    backgroundColor:
                        WidgetStateProperty.all<Color>(colorScheme.secondary),
                  ),
                  label: Text(
                    'Edit this aircraft',
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

  Future<void> changeAircraftDetails(String name) async {
    try {
      Map<String, dynamic> body = {
        "aircraft_id": _id,
        "name": name,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/aircrafts',
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
        'aircraft_id': id,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/aircrafts',
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
        'aircraft_id': id,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/aircrafts',
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
