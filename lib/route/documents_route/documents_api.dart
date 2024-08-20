part of 'document_class.dart';

class DocumentAPI extends DataTableSourceAsync {
  DocumentAPI();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "File name",
        "Subcategory",
        "Aircraft",
        "Archived",
        "Date",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Document> _documents = [];
  int _totalRecords = 0;
  @override
  int get totalRecords => _totalRecords;

  @override
  Future<void> fetchData(
      int startIndex, int count, CustomTableFilter filter) async {
    try {
      if (!filter.filterResults.containsKey('sort_column')) {
        filter.filterResults['sort_column'] = 'created_at';
        filter.filterResults['asc'] = false;
      }
      Map<String, String> queryParameters = {
        'offset': startIndex.toString(),
        'limit': count.toString()
      };
      queryParameters.addAll(filter.toJSON());
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/documents',
          apiName: 'adsatsStaffAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);

      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["documents"]);
      _documents = [for (var row in rowsData) Document.fromJSON(row)];
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  List<DataRow> get rows {
    return _documents.map((document) {
      return document.toDataRow(refreshDatasource);
    }).toList();
  }

  Map<String, String> get sqlColumns => {
        'File Name': 'file_name',
        'Archived': "archived",
        'Subcategory': 'sub_category',
        'Aircraft': 'aircraft',
        'Date': 'created_at',
      };

  @override
  Widget get header {
    return ListTile(
      contentPadding: const EdgeInsets.only(),
      leading: const Text(
        "Documents",
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
            AuthNotifier authNotifier =
                Provider.of<AuthNotifier>(context, listen: false);
            _filters.filterResults.addAll(
              {
                // 'limit_aircraft': staff.aircraft,
                // 'limit_subcategories': staff.subcategories,
                // 'limit_roles': staff.roles,
                // 'limit_categories': authNotifier.categories,
                // 'limit_author': authNotifier.email,
              },
            );
            return Row(
              children: [
                IconButton(
                  onPressed: () {
                    refreshDatasource();
                  },
                  icon: const Icon(Icons.refresh),
                ),
                if (authNotifier.id > -1)
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/add-a-document');
                    },
                    label: const Text('Add a document'),
                    icon: const Icon(
                      Icons.add,
                      size: 25,
                    ),
                  ),
                const SizedBox(
                  width: 10,
                ),
                FilterBy(
                  filters: _filters,
                  refreshDatasource: refreshDatasource,
                  filterByAuthors: true,
                  filterByRoles: true,
                  filterByAircraft: true,
                  filterByCategories: true,
                  filterBySubcategories: true,
                  filterByArchived: true,
                  filterByCreatedAt: true,
                ),
                const SizedBox(
                  width: 10,
                ),
                SortBy(
                  filters: _filters,
                  refreshDatasource: refreshDatasource,
                  sqlColumns: sqlColumns,
                ),
                const SizedBox(
                  width: 10,
                ),
                SearchBarWidget(
                  filters: _filters,
                  refreshDatasource: refreshDatasource,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
