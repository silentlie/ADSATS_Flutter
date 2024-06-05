import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

class Notice {
  Notice(
      {required int id,
      required bool archived,
      required String subject,
      required String category,
      required String author,
      DateTime? createdAt,
      DateTime? deadlineAt,
      String? documentsID,
      String? aircraft,
      bool? resolved})
      : _id = id,
        _archived = archived,
        _subject = subject,
        _category = category,
        _author = author,
        _createdAt = createdAt,
        _resolved = resolved,
        _deadlineAt = deadlineAt;
  final int _id;
  final bool _archived;
  final String _subject;
  final String _category;
  final String _author;
  final DateTime? _createdAt;
  final DateTime? _deadlineAt;
  final bool? _resolved;
  int get id => _id;
  bool get archived => _archived;
  String get subject => _subject;
  String get category => _category;
  String get author => _author;
  DateTime? get createdAt => _createdAt;
  DateTime? get deadlineAt => _deadlineAt;
  bool? get resolved => _resolved;
  Notice.fromJSON(Map<String, dynamic> json)
      : _id = json["notice_id"] as int,
        _subject = json["subject"] as String,
        _category = json["category"] as String,
        _author = json["author"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _resolved = intToBool(json["resolved"] as int),
        _createdAt = DateTime.parse(json["notice_at"]),
        _deadlineAt = DateTime.parse(json["deadline_at"]);
  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(cells: <DataCell>[
      cellFor(category),
      cellFor(subject),
      cellFor(author),
      cellFor(archived),
      cellFor(resolved),
      cellFor(createdAt),
      cellFor(deadlineAt),
      cellFor("actions"),
    ]);
  }

  // can rearrange collumn
  static List<String> columnNames = [
    "Category",
    "Subject",
    "Author",
    "Archived",
    "Resolved",
    "Notice Date",
    "Deadline At",
    "Actions",
  ];
}

class NoticeAPI extends DataTableSourceAsync {
  NoticeAPI();

  @override
  get showCheckBox => false;

  @override
  List<DataColumn> get columns {
    return List.generate(Notice.columnNames.length, (index) {
      String columnName = Notice.columnNames[index];
      return DataColumn(
          label: Text(
            columnName,
          ),
          tooltip: columnName);
    });
  }

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
        child: Row(
          children: [
            const SendANoticeButton(),
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
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Sort By function
              },
              child: const Text("Sort By"),
            ),
            const SizedBox(
              width: 10,
            ),
            SearchBarWidget(
              filters: filters,
              refreshDatasource: refreshDatasource,
            ),
          ],
        ),
      ),
    );
  }
}

class SendANoticeButton extends StatelessWidget {
  const SendANoticeButton({super.key});

  @override
  Widget build(BuildContext context) {
    // final buttonTheme = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: () {
        context.go('/send-notices');
      },
      // testing visual
      // style: ButtonStyle(
      //   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      //     RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //       side: const BorderSide(color: Colors.black),
      //     ),
      //   ),
      // ),
      child: const Row(
        children: [
          Icon(
            Icons.add,
            size: 30,
          ),
          SizedBox(width: 5),
          Text(
            'Create a new notification',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
