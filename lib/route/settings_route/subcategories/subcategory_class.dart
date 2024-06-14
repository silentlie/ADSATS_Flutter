import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';

part 'subcategories_api.dart';

class Subcategory {
  final int _id;
  final String _name;
  final String? _description;
  bool _archived;
  final String _category;

  int get id => _id;
  String get name => _name;
  String? get description => _description;
  bool get archived => _archived;
  String get category => _category;
  static List<String> categories = [];

  Subcategory.fromJSON(Map<String, dynamic> json)
      : _id = json["subcategory_id"] as int,
        _name = json["name"] as String,
        _description = json["description"] as String?,
        _archived = intToBool(json["archived"] as int)!,
        _category = json["category"] as String;

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
        DataCell(Text(name)),
        cellFor(description),
        cellFor(archived),
        cellFor(category),
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
    String subcategoryName = _name;
    String? description = _description;
    String category = _category;
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
                          subcategoryName = value!;
                        },
                        initialValue: name,
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
                        initialValue: this.description,
                      ),
                    ),
                    FutureBuilder(
                      future: getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // loading widget can be customise
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // can make it into a error widget for more visualise
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return DropdownMenu(
                            inputDecorationTheme: const InputDecorationTheme(
                                disabledBorder: InputBorder.none),
                            dropdownMenuEntries: categories.map(
                              (category) {
                                return DropdownMenuEntry(
                                    value: category, label: category);
                              },
                            ).toList(),
                            hintText: "Category?",
                            initialSelection: category,
                            label: const Text("Category?"),
                            onSelected: (value) {
                              category = value as String;
                            },
                          );
                        }
                      },
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
                      changeCategoryDetails(
                          subcategoryName, description, category);
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

  Future<void> changeCategoryDetails(
      String name, String? description, String category) async {
    try {
      Map<String, dynamic> body = {
        "subcategory_id": _id,
        "name": name,
        "category": category,
      };
      if (description != null) {
        body["description"] = description;
      }
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/sub-categories',
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

  Future<void> getCategories() async {
    try {
      final restOperation =
          Amplify.API.get('/categories', apiName: 'AmplifyAdminAPI');

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      debugPrint("finished fetch categories str");
      categories = List<String>.from(jsonDecode(jsonStr));
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> changeSubcategoryDetails(
      String name, String description, String category) async {
    try {
      Map<String, dynamic> body = {
        "role_id": _id,
        "name": name,
        "description": description,
        "category": category
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/sub-categories',
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
        'subcategory_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/sub-categories',
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
        'subcategory_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/sub-categories',
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
