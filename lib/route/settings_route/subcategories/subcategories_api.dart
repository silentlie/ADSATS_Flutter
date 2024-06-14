part of 'subcategory_class.dart';

class SubcategoriesApi extends DataTableSourceAsync {
  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames =>
      ["Name", "Description", "Archived", "Actions", "Category"];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Subcategory> _subcategories = [];
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
      final restOperation = Amplify.API.get('/sub-categories',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _subcategories = [for (var row in rowsData) Subcategory.fromJSON(row)];
      debugPrint("finished fetch table subcategories");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _subcategories.map((notice) {
      return notice.toDataRow(refreshDatasource);
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'Name': 'name',
        'Description': 'description',
        'Archived': "archived",
        'Category': "category",
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Subcategories",
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
                      // missing add staff after create subcategories
                      addNew(context);
                    },
                    label: const Text(
                      'Add new categories',
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
    String categoryName = '';
    String description = '';
    bool archived = false;
    String category = '';
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new subcategory"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Subcategory Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subcategory name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      categoryName = value!;
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
                  ),
                ),
                FutureBuilder(
                  future: getCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // loading widget can be customise
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // can make it into a error widget for more visualise
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        child: DropdownMenu(
                          dropdownMenuEntries: snapshot.data!.map(
                            (subcategory) {
                              return DropdownMenuEntry(
                                  value: subcategory, label: subcategory);
                            },
                          ).toList(),
                          hintText: "Category?",
                          initialSelection: snapshot.data![0],
                          label: const Text("Category?"),
                          onSelected: (value) {
                            category = value as String;
                          },
                        ),
                      );
                    } else {
                      return const Placeholder();
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
                  addNewSubcategory(
                      categoryName, description, archived, category);
                  Navigator.pop(context, 'Submit');
                }
              },
              style: ButtonStyle(
                // Change button background color
                backgroundColor:
                    WidgetStateProperty.all<Color>(colorScheme.secondary),
              ),
              label: Text(
                'Add this subcategory',
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
  }

  Future<void> addNewSubcategory(
      String name, String description, bool archived, String category) async {
    try {
      Map<String, dynamic> body = {
        "subcategory_name": name,
        "description": description,
        "archived": archived,
        "category": category
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/sub-categories',
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

  Future<List<String>> getCategories() async {
    try {
      final restOperation =
          Amplify.API.get('/categories', apiName: 'AmplifyAdminAPI');

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      // debugPrint("finished fetch categories str");
      return List<String>.from(jsonDecode(jsonStr));
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
