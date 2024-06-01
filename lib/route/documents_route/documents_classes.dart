import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'package:adsats_flutter/route/documents_route/filter_by.dart';

class Document {
  Document({
    required int id,
    required String fileName,
    required bool archived,
    required String email,
    required DateTime dateCreated,
    required String subcategory,
    required String category,
    String? aircraft,
  })  : _id = id,
        _fileName = fileName,
        _archived = archived,
        _email = email,
        _dateCreated = dateCreated,
        _subcategory = subcategory,
        _category = category,
        _aircraft = aircraft;
  Document.fromJSON(Map<String, dynamic> json)
      : _id = json["document_id"] as int,
        _fileName = json["file_name"] as String,
        _archived = intToBool(json["archived"] as int),
        _email = json["email"] as String,
        _dateCreated = DateTime.parse(json["created_at"]),
        _subcategory = json["sub_category"] as String,
        _category = json["category"] as String,
        _aircraft = json["aircrafts"] as String?;
  final int _id;
  final String _fileName;
  final bool? _archived;
  final String _email;
  final DateTime _dateCreated;
  final String _category;
  final String _subcategory;
  final String? _aircraft;
  int get id => _id;
  String get fileName => _fileName;
  bool? get archived => _archived;
  String get email => _email;
  DateTime get dateCreated => _dateCreated;
  String get subcategory => _subcategory;
  String get category => _category;
  String? get aircraft => _aircraft;
  static bool intToBool(int value) {
    return value != 0;
  }

  DataRow toDataRow() {
    return DataRow(cells: <DataCell>[
      cellFor(fileName),
      cellFor(email),
      cellFor(archived),
      cellFor(dateCreated),
      cellFor(subcategory),
      cellFor(category),
      cellFor(aircraft),
      cellFor("actions"),
    ]);
  }

  static List<String> columnNames = [
    "File name",
    "Author",
    "Archived",
    "Date",
    "Sub category",
    "Category",
    "Aircrafts",
    "Actions",
  ];
}

class DocumentAPI extends DataTableSourceAsync {
  DocumentAPI();

  @override
  List<DataColumn> get columns {
    return List.generate(Document.columnNames.length, (index) {
      String columnName = Document.columnNames[index];
      return DataColumn(
          label: Text(
            columnName,
          ),
          tooltip: columnName);
    });
  }

  @override
  get showCheckBox => false;
  final CustomTableFilter _filters = CustomTableFilter();

  Future<void> fetchData(
      int startIndex, int count, CustomTableFilter filter) async {
    try {
      Map<String, String> queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
      queryParameters.addAll(filter.toJSON());
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/documents',
          apiName: 'AmplifyCrewAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);
      List<Document> tempList = [];
      for (var row in rowsData) {
        tempList.add(Document.fromJSON(row));
      }
      _documents = tempList;

      debugPrint("finished fetch table data");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      _totalRecords = 0;
      _documents = [];
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  List<Document> _documents = [];
  int _totalRecords = 0;
  @override
  int get totalRecords => _totalRecords;

  List<DataRow> get rows {
    return _documents.map((document) {
      return document.toDataRow();
    }).toList();
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    try {
      // implement filtering
      await fetchData(startIndex, count, _filters);
      AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
      return response;
    } on Error catch (e) {
      debugPrint('Error: $e');
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
        const AddADocumentButton(),
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

class AddADocumentButton extends StatelessWidget {
  const AddADocumentButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.go('/add-a-document');
      },
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF05ABC4)),
          ),
        ),
      ),
      child: const Text('+ Add a document'),
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

class FilterByButton extends StatelessWidget {
  const FilterByButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => const FilterByAlertDialog()),
      child: const Text("Filter By"),
    );
  }
}
