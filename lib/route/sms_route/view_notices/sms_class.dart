import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:provider/provider.dart';

part 'sms_api.dart';

class Notice {
  final int _id;
  bool _archived;
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
        _createdAt = json["notice_at"] != null
            ? DateTime.parse(json["notice_at"])
            : null,
        _deadlineAt = json["deadline_at"] != null
            ? DateTime.parse(json["deadline_at"])
            : null;
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
        cellFor(category),
        cellFor(subject),
        cellFor(author),
        cellFor(archived),
        cellFor(resolved),
        cellFor(createdAt),
        cellFor(deadlineAt),
        DataCell(
          Builder(builder: (context) {
            AuthNotifier authNotifier =
                Provider.of<AuthNotifier>(context, listen: false);
            List<Widget> children = [
              IconButton(
                onPressed: () {
                  // TODO: view notice
                },
                icon: const Icon(Icons.remove_red_eye_outlined),
                tooltip: 'View',
              ),
            ];
            if (authNotifier.isAdmin || authNotifier.isEditor) {
              children.addAll([
                IconButton(
                  onPressed: () async {
                    // TODO: view notice and edit it
                    refreshDatasource();
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () async {
                    await archive();
                    refreshDatasource();
                  },
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'Archive',
                ),
              ]);
            }
            if (authNotifier.isAdmin) {
              children.add(
                IconButton(
                  onPressed: () async {
                    await delete();
                    refreshDatasource();
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            );
          }),
        ),
      ],
    );
  }

  Future<void> archive() async {
    try {
      Map<String, dynamic> body = {
        'archived': !_archived,
        'notice_id': id,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/sms',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

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
        'notice_id': id,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/sms',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

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
