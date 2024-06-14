part of 'category_class.dart';

class CategoriesApi extends DataTableSourceAsync {
  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "Name",
        "Archived",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Category> _categories = [];
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
      final restOperation = Amplify.API.get('/categories',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _categories = [for (var row in rowsData) Category.fromJSON(row)];
      // debugPrint("finished fetch table categories");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _categories.map((notice) {
      return notice.toDataRow(refreshDatasource);
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'Name': 'name',
        'Archived': "archived",
      };

  @override
  Widget get header => ListTile(
        contentPadding: const EdgeInsets.only(),
        leading: const Text(
          "Categories",
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
                      // missing add staff after create categories
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
    bool archived = false;
    List<String> emails = [];
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add new category"),
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
                  addNewCategory(categoryName, archived, emails);
                  Navigator.pop(context, 'Submit');
                }
              },
              style: ButtonStyle(
                // Change button background color
                backgroundColor:
                    WidgetStateProperty.all<Color>(colorScheme.secondary),
              ),
              label: Text(
                'Add this category',
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

  Future<void> addNewCategory(
      String name, bool archived, List<String> emails) async {
    try {
      Map<String, dynamic> body = {"category_name": name, "archived": archived};
      if (emails.isNotEmpty) {
        body["staff"] = emails;
      }
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/categories',
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
