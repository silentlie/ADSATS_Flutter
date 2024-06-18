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
      if (!filter.filterResults.containsKey('sort_column')) {
        filter.filterResults['sort_column'] = 'notice_at';
        filter.filterResults['asc'] = false;
      }
      Map<String, String> queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
      queryParameters.addAll(filter.toJSON());
      // debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/notices',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _notices = [for (var row in rowsData) Notice.fromJSON(row)];
      // debugPrint("finished fetch table data");
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
      return notice.toDataRow(refreshDatasource);
    }).toList();
  }

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
          AuthNotifier authNotifier =
              Provider.of<AuthNotifier>(context, listen: false);
          _filters.filterResults['staff_id'] = authNotifier.staffID;
          return Row(
            children: [
              Text('KPI: $_totalRecords'),
              IconButton(
                onPressed: () {
                  refreshDatasource();
                },
                icon: const Icon(Icons.refresh),
              ),
              if (authNotifier.staffID > -1)
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
                filterByNoticeTypes: true,
                filterByCreatedAt: true,
                filterByDeadlineAt: true,
                filterByRoles: true,
                filterByAuthors: true,
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
        }),
      ),
    );
  }
}
