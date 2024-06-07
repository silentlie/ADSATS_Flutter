import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';

part 'roles_api.dart';

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
    return DataRow(
      cells: <DataCell>[
        cellFor(name),
        cellFor(archived),
        cellFor(description),
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
