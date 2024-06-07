import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

part 'aircrafts_api.dart';

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
  final bool _archived;
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
  DataRow toDataRow() {
    return DataRow(
      cells: <DataCell>[
        cellFor(name),
        cellFor(archived),
        cellFor(createdAt),
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
