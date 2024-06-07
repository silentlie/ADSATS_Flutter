part of 'sms_class.dart';

class NoticeAPI extends DataTableSourceAsync {
  NoticeAPI();

  @override
  get showCheckBox => false;

  // can rearrange collumn
  @override
  List<String> get columnNames => [
        "Category",
        "Subject",
        "Author",
        "Archived",
        "Resolved",
        "Notice Date",
        "Deadline At",
        "Actions",
      ];

  final CustomTableFilter _filters = CustomTableFilter();
  @override
  CustomTableFilter get filters => _filters;
  List<Notice> _notices = [];
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
      final restOperation = Amplify.API.get('/notices',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _notices = [for (var row in rowsData) Notice.fromJSON(row)];
      debugPrint(_notices.length.toString());
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
    return _notices.map((notice) {
      return notice.toDataRow();
    }).toList();
  }

  Map<String, String> get filterEndpoints => {
        'authors': '/staff',
        // filter by roles could be more complex then it should
        // 'roles': '/roles',
        'aircrafts': '/aircrafts',
        'categories': '/categories',
        'sub-categories': '/sub-categories',
      };
  Map<String, String> get sqlColumns => {
        'Subject': 'subject',
        'Category': 'category',
        'Author': 'email',
        'Date': 'notice_at',
        'Deadline': 'deadline_at',
        'Archived': 'archived',
        'Resolved': 'resolved',
      };
  @override
  Widget get header {
    return ListTile(
      contentPadding: const EdgeInsets.only(bottom: 5),
      leading: const Text(
        "Notices",
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
                  context.go('/send-notices');
                },
                label: const Text('Create a new notification'),
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
                filterEndpoints: filterEndpoints,
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
}
