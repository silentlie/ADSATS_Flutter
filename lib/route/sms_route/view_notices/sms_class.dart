import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

part 'sms_api.dart';
class Notice {
  Notice(
      {required int id,
      required bool archived,
      required String subject,
      required String category,
      required String author,
      DateTime? createdAt,
      DateTime? deadlineAt,
      String? documentsID,
      String? aircraft,
      bool? resolved})
      : _id = id,
        _archived = archived,
        _subject = subject,
        _category = category,
        _author = author,
        _createdAt = createdAt,
        _resolved = resolved,
        _deadlineAt = deadlineAt;
  final int _id;
  final bool _archived;
  final String _subject;
  final String _category;
  final String _author;
  final DateTime? _createdAt;
  final DateTime? _deadlineAt;
  final bool? _resolved;
  int get id => _id;
  bool get archived => _archived;
  String get subject => _subject;
  String get category => _category;
  String get author => _author;
  DateTime? get createdAt => _createdAt;
  DateTime? get deadlineAt => _deadlineAt;
  bool? get resolved => _resolved;
  Notice.fromJSON(Map<String, dynamic> json)
      : _id = json["notice_id"] as int,
        _subject = json["subject"] as String,
        _category = json["category"] as String,
        _author = json["author"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _resolved = intToBool(json["resolved"] as int),
        _createdAt = DateTime.parse(json["notice_at"]),
        _deadlineAt = DateTime.parse(json["deadline_at"]);
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
        cellFor(category),
        cellFor(subject),
        cellFor(author),
        cellFor(archived),
        cellFor(resolved),
        cellFor(createdAt),
        cellFor(deadlineAt),
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