import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

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
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.archive_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.delete_outline)),
            ],
          ),
        ),
      ],
    );
  }
}
