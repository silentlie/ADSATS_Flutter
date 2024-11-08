part of 'aircraft_class.dart';

class AircraftAPI extends DataTableSourceAsync {
  AircraftAPI();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "Name",
        "Archived",
        "Created At",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Aircraft> _aircraft = [];
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
      final restOperation = Amplify.API.get('/aircraft',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _aircraft = [for (var row in rowsData) Aircraft.fromJSON(row)];
      debugPrint(_aircraft.length.toString());
      // debugPrint("finished fetch table aircraft");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _aircraft.map((notice) {
      return notice.toDataRow(refreshDatasource);
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'Name': 'name',
        'Archived': "archived",
        'Start Date': 'created_at',
        // missing end date column?
        // 'End Date': 'end_at',
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Aircraft",
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
                      // missing add staff after create aircraft
                      addNew(context);
                    },
                    label: const Text(
                      'Add new aircraft',
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
    String aircraftName = '';
    DateTime? createAt;
    String? dateError;
    bool archived = false;
    List<String> emails = [];
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add new aircraft"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Aircraft Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter aircraft name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          aircraftName = value!;
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
                              debugPrint(createAt!.toIso8601String());
                              dateError = null;
                            });
                          }
                        },
                        label: createAt == null
                            ? const Text("Pick start date")
                            : Text(
                                createAt!.toIso8601String(),
                              ),
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
                      items: authNotifier.staffCache.entries.map(
                        (entry) {
                          return MultiSelectItem(
                            entry.key,
                            entry.value,
                          );
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
                    if (createAt == null) {
                      setState(() {
                        dateError = 'Please pick a date';
                      });
                      return;
                    }
                    if (formKey.currentState!.validate() && createAt != null) {
                      formKey.currentState!.save();
                      addNewAircraft(aircraftName, createAt!, archived, emails);
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

  Future<void> addNewAircraft(String name, DateTime createdAt, bool archived,
      List<String> emails) async {
    try {
      Map<String, dynamic> body = {
        "aircraftName": name,
        "created_at": createdAt.toIso8601String(),
        "archived": archived,
      };
      if (emails.isNotEmpty) {
        body["staff"] = emails;
      }
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/aircraft',
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
