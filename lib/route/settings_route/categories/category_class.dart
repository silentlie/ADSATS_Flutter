import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';

part 'categories_api.dart';

class Category {
  final int _id;
  final String _name;
  bool _archived;
  int get id => _id;
  String get name => _name;
  bool get archived => _archived;

  Category.fromJSON(Map<String, dynamic> json)
      : _id = json["category_id"] as int,
        _name = json["name"] as String,
        _archived = intToBool(json["archived"] as int)!;

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
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  onPressed: () {
                    archive();
                  },
                  icon: const Icon(Icons.archive_outlined),
                ),
                IconButton(
                  onPressed: () {
                    delete();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void changeDetails(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String categoryName = '';
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change category details"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter category name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          categoryName = value!;
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
                      changeCategoryDetails(categoryName);
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

  Future<void> changeCategoryDetails(String name) async {
    try {
      Map<String, dynamic> body = {
        "category_id": _id,
        "name": name,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/categories',
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
        'category_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/categories',
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
        'category_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/categories',
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