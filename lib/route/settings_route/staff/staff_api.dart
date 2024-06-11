part of 'staff_class.dart';

class StaffApi extends DataTableSourceAsync {
  StaffApi();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "First Name",
        "Last Name",
        "Email",
        "Archived",
        "Created At",
        "Roles",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Staff> _staff = [];
  int _totalRecords = 0;
  @override
  int get totalRecords => _totalRecords;

  @override
  Future<void> fetchData(
      int startIndex, int count, CustomTableFilter filter) async {
    try {
      Map<String, String> queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
      queryParameters.addAll(filter.toJSON());
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/staff',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _staff = [for (var row in rowsData) Staff.fromJSON(row)];
      debugPrint("finished fetch table staff");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _staff.map((notice) {
      return notice.toDataRow();
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'First Name': 'f_name',
        'Last Name': 'l_name',
        'Email': 'email',
        'Archived': "archived",
        'Date': 'created_at',
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Staff",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        title: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 5),
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Builder(
            builder: (context) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () {
                      refreshDatasource();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  const AddStaff(),
                  const SizedBox(
                    width: 10,
                  ),
                  FilterBy(
                    filters: filters,
                    refreshDatasource: refreshDatasource,
                    filterByArchived: true,
                    filterByCreatedAt: true,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SortBy(
                      filters: filters,
                      refreshDatasource: refreshDatasource,
                      sqlColumns: sqlColumns),
                  const SizedBox(
                    width: 10,
                  ),
                  SearchBarWidget(
                    filters: filters,
                    refreshDatasource: refreshDatasource,
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class AddStaff extends StatelessWidget {
  const AddStaff({super.key});

  static Map<String, String> filterEndpoints = {
    'roles': '/roles',
    'aircraft': '/aircrafts',
    'categories': '/categories'
  };

  Future<Map<String, List<MultiSelectItem>>> fetchFilter(
      Map<String, String>? filterEndpoints) async {
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
          filterEndpoints?.values.map(fetchData).toList() ?? [];

      List<List<String>> results = await Future.wait(futures);
      // Function to map List<String> to List<ValueItem>
      List<MultiSelectItem> mapToValueItemList(List<String> list) {
        return list.map((item) => MultiSelectItem(item, item)).toList();
      }

      List<String> keys = filterEndpoints?.keys.toList() ?? [];
      List<List<MultiSelectItem>> values =
          results.map(mapToValueItemList).toList();
      Map<String, List<MultiSelectItem>> mappedResults =
          Map.fromIterables(keys, values);
      // Process the results
      safePrint("did fetch Filter");
      return mappedResults;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    // based on html standard
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    // list of title of each filter
    List<String> filterTitles = filterEndpoints.keys.toList();
    return ElevatedButton.icon(
      onPressed: () {
        final formKey = GlobalKey<FormState>();
        String firstName = '';
        String lastName = '';
        String email = '';
        Map<String, String> result = {};
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
                      ),
                    ),
                    FutureBuilder(
                      future: fetchFilter(filterEndpoints),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // loading widget can be customise
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // can make it into a error widget for more visualise
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          // if data is fetch successfully
                          Map<String, List<MultiSelectItem>> filterData =
                              snapshot.data!;
                          // generate MultiSelectDialogField based on how many filter in filterData
                          List<Widget> filterContent = List.generate(
                            filterData.length,
                            (index) {
                              // customise for visual, right now
                              return Container(
                                padding: const EdgeInsets.all(8),
                                constraints:
                                    const BoxConstraints(maxWidth: 300),
                                child: MultiSelectDialogField(
                                  // get text based on index
                                  buttonText:
                                      Text("Add ${filterTitles[index]}"),
                                  // get list of item from fetchData
                                  items: filterData[filterTitles[index]]!,
                                  // send selected item to filterResult
                                  onConfirm: (selectedOptions) {
                                    result[filterTitles[index]] =
                                        List<String>.from(selectedOptions)
                                            .join(',');
                                  },
                                  title: Text("Add ${filterTitles[index]}"),
                                  searchable: true,
                                  // size of dialog after click each filter
                                  dialogHeight: 714,
                                  dialogWidth: 400,
                                  // can be specify based on ThemeData
                                  itemsTextStyle:
                                      const TextStyle(color: Colors.amber),
                                  selectedItemsTextStyle:
                                      const TextStyle(color: Colors.blue),
                                  cancelText: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.amber),
                                  ),
                                  confirmText: const Text(
                                    "Confirm",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  chipDisplay: MultiSelectChipDisplay(
                                    scroll: true,
                                    scrollBar: HorizontalScrollBar(
                                        isAlwaysShown: true),
                                  ),
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
                      // may need add pick date and archived or not
                      addNewStaff(firstName, lastName, email, DateTime.now(),
                          false, result);
                      Navigator.pop(context, 'Submit');
                    }
                  },
                  style: ButtonStyle(
                    // Change button background color
                    backgroundColor:
                        WidgetStateProperty.all<Color>(colorScheme.secondary),
                  ),
                  label: Text(
                    'Add this user',
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
      label: const Text(
        'Add new staff',
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      icon: const Icon(
        Icons.add,
        size: 25,
      ),
    );
  }

  Future<void> addNewStaff(
    String firstName,
    String lastName,
    String email,
    DateTime createdAt,
    bool archived,
    Map<String, String> result,
  ) async {
    try {
      Map<String, dynamic> body = {
        "f_name": firstName,
        "l_name": lastName,
        "email": email,
        "created_at": createdAt.toIso8601String(),
        "archived": archived
      };
      if (result.isNotEmpty) {
        body.addAll(result);
      }
      debugPrint(body.toString());
      final restOperation = Amplify.API.post('/staff',
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
}
