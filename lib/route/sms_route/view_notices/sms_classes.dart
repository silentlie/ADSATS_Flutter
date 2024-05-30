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

  Future<void> fetchData(int startIndex, int count,
      [CustomTableFilter? filter]) async {
    // TODO: implement getData one API finish
    debugPrint("fetch Data");
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

  CustomTableFilter? _filters;

  final TextEditingController _textEditingController = TextEditingController();
  Widget get _header {
    return Row(
      children: [
        const Text(
          'My Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const SendANoticeButton(),
        // TODO: implement search function
        const Spacer(),
        SearchBar(
          constraints: const BoxConstraints(
            maxWidth: 360,
          ),
          leading: const Icon(Icons.search),
          controller: _textEditingController,
          onSubmitted: (value) {
            refreshDatasource();
          },
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: implement filter function
          },
          child: const Text("Filter By"),
        ),
      ],
    );
  }

  @override
  Widget get header => _header;
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

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key});

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      constraints: const BoxConstraints(
        maxWidth: 360,
      ),
      leading: const Icon(Icons.search),
      controller: _textEditingController,
    );
  }
}
