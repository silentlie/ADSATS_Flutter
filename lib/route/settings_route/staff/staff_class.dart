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
        _roles = json["l_name"] as String?;

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

  Future<Map<String, dynamic>> fetchStaffDetails(String email) async {
    try {
      Map<String, String> queryParameters = {
        "email": email,
      };
      debugPrint(DateTime.now().toIso8601String());
      final restOperation = Amplify.API.get(
        '/staff',
        apiName: 'AmplifyFilterAPI',
        queryParameters: queryParameters,
      );
      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      dynamic raw = jsonDecode(jsonStr);
      if (raw.isEmpty) {
        return {};
      }
      Map<String, dynamic> rawData = jsonDecode(jsonStr)[0];
      return rawData;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  static Map<String, String> filterEndpoints = {
    'roles': '/roles',
    'aircraft': '/aircrafts',
    'categories': '/categories'
  };

  Future<Map<String, dynamic>> fetchFilterAndStaff() async {
    try {
      // Function to make API requests and return the parsed response
      Future<List<String>> fetchData(String endpoint) async {
        RestOperation restOperation =
            Amplify.API.get(endpoint, apiName: 'AmplifyFilterAPI');
        AWSHttpResponse response = await restOperation.response;
        String jsonStr = response.decodeBody();
        // Map<String, dynamic> rawData = jsonDecode(jsonStr);
        return List<String>.from(jsonDecode(jsonStr));
      }

      // Perform all fetches concurrently
      List<Future<List<String>>> futures =
          filterEndpoints.values.map(fetchData).toList();

      List<List<String>> results = await Future.wait(futures);
      // Function to map List<String> to List<ValueItem>
      List<MultiSelectItem> mapToValueItemList(List<String> list) {
        return list.map((item) => MultiSelectItem(item, item)).toList();
      }

      List<String> keys = filterEndpoints.keys.toList();
      List<List<MultiSelectItem>> values =
          results.map(mapToValueItemList).toList();
      final mappedResults =
          Map<String, List<MultiSelectItem>>.fromIterables(keys, values);

      safePrint("did fetch Filters");
      Map<String, dynamic> staff = await fetchStaffDetails(email);

      return {
        "filters": mappedResults,
        "staff": staff,
      };
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void changeDetails(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    String firstName = this.firstName;
    String lastName = this.lastName;
    String email = this.email;
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    List<String> filterTitles = filterEndpoints.keys.toList();
    Map<String, dynamic> result = {};
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      firstName = value!;
                    },
                    initialValue: this.firstName,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      lastName = value!;
                    },
                    initialValue: this.lastName,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!emailRegExp.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!;
                    },
                    initialValue: this.email,
                  ),
                ),
                FutureBuilder(
                  future: fetchFilterAndStaff(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // loading widget can be customise
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // can make it into a error widget for more visualise
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      // if data is fetch successfully
                      Map<String, dynamic> data = snapshot.data!;
                      // generate MultiSelectDialogField based on how many filter in filterData
                      Map<String, List<MultiSelectItem>> filterData =
                          data["filters"];
                      Map<String, dynamic> staff = data["staff"];
                      List<Widget> filterContent = List.generate(
                        filterData.length,
                        (index) {
                          final initialData = staff[filterTitles[index]]
                                  ?.toString()
                                  .split(',')
                                  .map(
                                (e) {
                                  return e.trim();
                                },
                              ).toList() ??
                              [];
                          debugPrint(initialData.toString());
                          // customise for visual, right now

                          return Container(
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: MultiSelect(
                              // get text based on index
                              title: Text("Add ${filterTitles[index]}"),
                              buttonText: Text("Add ${filterTitles[index]}"),
                              // get list of item from fetchData
                              items: filterData[filterTitles[index]]!,
                              // send selected item to filterResult
                              onConfirm: (selectedOptions) {
                                result[filterTitles[index]] =
                                    List<String>.from(selectedOptions);
                              },
                              initialValue: initialData,
                            ),
                          );
                        },
                      );
                      // return column with filter content
                      return Column(
                        children: filterContent,
                      );
                    } else {
                      return const Placeholder();
                    }
                  },
                )
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, 'Cancel');
              },
              label: const Text('Cancel'),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  // may need add pick date and archived or not
                  changeStaffDetails(firstName, lastName, email, result);
                  Navigator.pop(context, 'Submit');
                }
              },
              style: ButtonStyle(
                // Change button background color
                backgroundColor:
                    WidgetStateProperty.all<Color>(colorScheme.secondary),
              ),
              label: Text(
                'Update this user',
                style: TextStyle(color: colorScheme.onSecondary),
              ),
              icon: Icon(
                Icons.add,
                color: colorScheme.onSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> changeStaffDetails(
    String firstName,
    String lastName,
    String email,
    Map<String, dynamic> result,
  ) async {
    try {
      Map<String, dynamic> body = {
        "staff_id": _id,
        "f_name": firstName,
        "l_name": lastName,
        "email": email,
      };
      if (result.isNotEmpty) {
        body.addAll(result);
      }
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
