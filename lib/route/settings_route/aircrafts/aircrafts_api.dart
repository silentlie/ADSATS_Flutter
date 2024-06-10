part of 'aircraft_class.dart';

class AircraftsAPI extends DataTableSourceAsync {
  AircraftsAPI();

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
  List<Aircraft> _aircrafts = [];
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
      final restOperation = Amplify.API.get('/aircrafts',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _aircrafts = [for (var row in rowsData) Aircraft.fromJSON(row)];
      debugPrint(_aircrafts.length.toString());
      debugPrint("finished fetch table data");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _aircrafts.map((notice) {
      return notice.toDataRow();
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
          "Aircrafts",
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
                      // missing add staff after create aircrafts
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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
                            : Text(createAt!.toIso8601String()),
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
                      if (createAt == null) {
                        setState(() {
                          dateError = 'Please pick a date';
                        });
                        return;
                      }
                      formKey.currentState!.save();
                      addNewAircraft(aircraftName, createAt!, archived);
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

  Future<void> addNewAircraft(
      String name, DateTime createdAt, bool archived) async {
    try {
      Map<String, dynamic> body = {
        "aircraftName": name,
        "created_at": createdAt.toIso8601String(),
        "archived": archived
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.post('/aircrafts',
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
