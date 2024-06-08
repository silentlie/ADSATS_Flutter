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
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/roles',
          apiName: 'AmplifyAdminAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _roles = [for (var row in rowsData) Role.fromJSON(row)];
      debugPrint(_roles.length.toString());
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
    return _roles.map((notice) {
      return notice.toDataRow();
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
                  ElevatedButton.icon(
                  onPressed: () {
                    // TODO: add new role
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
            }
          ),
        ),
      );
}
