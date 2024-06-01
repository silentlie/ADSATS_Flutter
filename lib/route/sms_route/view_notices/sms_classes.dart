import 'package:adsats_flutter/route/sms_route/view_notices/filter_by.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'mock_data.dart';

class Notice {
  Notice(
      {required int id,
      required bool read,
      required String subject,
      required String category,
      required String author,
      required DateTime createAt,
      String? reportNumber,
      DateTime? deadlineAt,
      List<int>? documentsID,
      String? aircraft,
      bool? resolved})
      : _id = id,
        _read = read,
        _subject = subject,
        _category = category,
        _author = author,
        _createAt = createAt,
        _documentsID = documentsID,
        _resolved = resolved,
        _deadlineAt = deadlineAt,
        _reportNumber = reportNumber,
        _aircraft = aircraft;
  final int _id;
  final bool _read;
  final String _subject;
  final String _category;
  final String _author;
  final String? _aircraft;
  final String? _reportNumber;
  final DateTime _createAt;
  final DateTime? _deadlineAt;
  final bool? _resolved;
  final List<int>? _documentsID;
  int get id => _id;
  bool get read => _read;
  String get subject => _subject;
  String get category => _category;
  String get author => _author;
  String? get aircraft => _aircraft;
  String? get reportNumber => _reportNumber;
  DateTime get createAt => _createAt;
  DateTime? get deadlineAt => _deadlineAt;
  bool? get resolved => _resolved;
  List<int>? get documentsID => _documentsID;
}

class NoticeAPI extends DataTableSourceAsync {
  NoticeAPI();

  @override
  get showCheckBox => false;

  List<String> get columnNames => [
        "Subject",
        "Read",
        "Category",
        "Author",
        "Aircraft",
        "Notice Date",
        "Resolved",
      ];

  @override
  List<DataColumn> get columns {
    return List.generate(columnNames.length, (index) {
      String columnName = columnNames[index];
      return DataColumn(
          label: Text(
            columnName,
          ),
          tooltip: columnName);
    });
  }

  List<DataRow> get rows {
    return notices.map(
      (object) {
        Notice notice = object;
        return DataRow(cells: <DataCell>[
          cellFor(notice.subject),
          cellFor(notice.read),
          cellFor(notice.category),
          cellFor(notice.author),
          cellFor(notice.aircraft),
          cellFor(notice.createAt),
          cellFor(notice.resolved),
        ]);
      },
    ).toList();
  }

  final CustomTableFilter _filters = CustomTableFilter();
  Future<void> fetchData(int startIndex, int count,
      [CustomTableFilter? filter]) async {
    // TODO: implement getData one API finish
  }

  @override
  int get totalRecords {
    // TODO: implement get totalRecords once API finish
    return notices.length;
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    try {
      // implement filtering
      await fetchData(startIndex, count, _filters);
      AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
      return response;
    } on Error catch (e) {
      safePrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget get header => Header(
        filter: _filters,
        refreshDatasource: refreshDatasource,
      );
}

class Header extends StatelessWidget {
  const Header(
      {super.key, required this.filter, required this.refreshDatasource});
  final CustomTableFilter filter;
  final Function refreshDatasource;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Documents",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const SendANoticeButton(),
        const Spacer(),
        SearchBarWidget(
          filter: filter,
          refreshDatasource: refreshDatasource,
        ),
        const SizedBox(
          width: 10,
        ),
        FilterBy(
          filter: filter,
          refreshDatasource: refreshDatasource,
        ),
      ],
    );
  }
}

class SendANoticeButton extends StatelessWidget {
  const SendANoticeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go('/send-notices');
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black),
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.add,
            size: 30,
          ),
          SizedBox(width: 5),
          Text(
            'Send a notice',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
