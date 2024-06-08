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
      debugPrint(_staff.length.toString());
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
          child: Builder(builder: (context) {
            return Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: add new staff
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
          }),
        ),
      );
}
