import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

part 'staff_api.dart';

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
  bool _archived;
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
    return DataRow(
      cells: <DataCell>[
        cellFor(firstName),
        cellFor(lastName),
        cellFor(email),
        cellFor(archived),
        cellFor(createdAt),
        cellFor(roles),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // IconButton(
              //     onPressed: () {},
              //     icon: const Icon(Icons.remove_red_eye_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
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
          ),
        ),
      ],
    );
  }

  Future<void> changeStaffDetails(
    String firstName,
    String lastName,
    String email,
    List<String> aircraft,
    List<String> roles,
    List<String> categories,
  ) async {
    try {
      Map<String, dynamic> body = {
        "staff_id": _id,
        "fName": firstName,
        "lName": lastName,
        "email": email,
        "aircraft": aircraft,
        "roles": roles,
        "categories": categories
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/staff',
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
        'staff_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/staff',
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
        'staff_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/staff',
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
