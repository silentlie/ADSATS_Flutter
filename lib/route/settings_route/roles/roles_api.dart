part of 'role_class.dart';

class RolesAPI extends DataTableSourceAsync {
  RolesAPI();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "Name",
        "Archived",
        "Description",
        "Created At",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Role> _roles = [];
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
      // debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/roles',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);
      _roles = [for (var row in rowsData) Role.fromJSON(row)];
      // debugPrint("finished fetch table roles");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _roles.map((notice) {
      return notice.toDataRow(refreshDatasource);
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'Role': 'role',
        'Archived': "archived",
        'Description': 'description',
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Roles",
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
                  ElevatedButton.icon(
                    onPressed: () {
                      // missing add staff after create roles
                      addNew(context);
                    },
                    label: const Text(
                      'Add new role',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      size: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
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

  void addNew(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String roleName = '';
    String description = '';
    DateTime? createAt;
    String? dateError;
    bool archived = false;
    List<String> emails = [];
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add new roles"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Role Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter role name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          roleName = value!;
                        },
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
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.all(8),
                        child: DropdownMenu(
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(label: "True", value: true),
                            DropdownMenuEntry(value: false, label: "False")
                          ],
                          hintText: "Archived?",
                          initialSelection: false,
                          label: const Text("Archived?"),
                          onSelected: (value) {
                            archived = value!;
                          },
                        )),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null && picked != createAt) {
                            setState(() {
                              createAt = picked;
                              // debugPrint(createAt!.toIso8601String());
                              dateError = null;
                            });
                          }
                        },
                        label: createAt == null
                            ? const Text("Pick start date")
                            : Text(createAt!.toIso8601String()),
                        icon: const Icon(Icons.edit_calendar_outlined),
                      ),
                    ),
                    if (dateError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          dateError!,
                          // style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      ),
                    MultiSelect(
                      buttonText: const Text("Add staff"),
                      title: const Text("Add staff"),
                      onConfirm: (selectedOptions) {
                        emails = List<String>.from(selectedOptions);
                      },
                      items: authNotifier.staff.map(
                        (staff) {
                          return MultiSelectItem(staff, staff);
                        },
                      ).toList(),
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
                      if (createAt == null) {
                        setState(() {
                          dateError = 'Please pick a date';
                        });
                        return;
                      }
                      formKey.currentState!.save();
                      addNewRole(
                          roleName, description, createAt!, archived, emails);
                      Navigator.pop(context, 'Submit');
                    }
                  },
                  style: ButtonStyle(
                    // Change button background color
                    backgroundColor:
                        WidgetStateProperty.all<Color>(colorScheme.secondary),
                  ),
                  label: Text(
                    'Add this aircraft',
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
      },
    );
  }

  Future<void> addNewRole(String name, String description, DateTime createdAt,
      bool archived, List<String> emails) async {
    try {
      Map<String, dynamic> body = {
        "role": name,
        "description": description,
        "created_at": createdAt.toIso8601String(),
        "archived": archived
      };
      if (emails.isNotEmpty) {
        body["staff"] = emails;
      }
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/roles',
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
