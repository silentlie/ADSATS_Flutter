import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'package:adsats_flutter/route/documents_route/filter_by2.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

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

  Future<void> fetchData(int startIndex, int count,
      [CustomTableFilter? filter]) async {
    try {
      Map<String, String> queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
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

  Future<List<Widget>> get filterContent async {
    List<List<ValueItem>> filterData = await fetchFilter();
    List<List<ValueItem>> filterResult = List.generate(filterData.length, (index) => []);
    return List.generate(
      filterData.length,
      (index) {
        return MultiSelectDropDown(
            onOptionSelected: (selectedOptions) {
              filterResult[index] = selectedOptions;
            },
            options: filterData[index]);
      },
    );
  }

  Future<List<List<ValueItem>>> fetchFilter() async {
    try {
      // Function to make API requests and return the parsed response
      Future<List<Map<String, dynamic>>> fetchData(String endpoint) async {
        var restOperation =
            Amplify.API.get(endpoint, apiName: 'AmplifyCrewAPI');
        var response = await restOperation.response;
        String jsonStr = response.decodeBody();
        Map<String, dynamic> rawData = jsonDecode(jsonStr);
        return List<Map<String, dynamic>>.from(rawData["rows"]);
      }

      // Perform all fetches concurrently
      List<Future<List<Map<String, dynamic>>>> futures = [
        fetchData('/crews'),
        fetchData('/roles'),
        fetchData('/aircrafts'),
        fetchData('/categories'),
        fetchData('/sub-categories'),
      ];

      List<List<Map<String, dynamic>>> results = await Future.wait(futures);

      // Process the results
      List<ValueItem> emails = results[0]
          .map((row) => ValueItem(label: row["email"], value: row["email"]))
          .toList();
      List<ValueItem> roles = results[1]
          .map((row) => ValueItem(label: row["role"], value: row["role"]))
          .toList();
      List<ValueItem> aircrafts = results[2]
          .map((row) => ValueItem(label: row["name"], value: row["name"]))
          .toList();
      List<ValueItem> categories = results[3]
          .map((row) => ValueItem(label: row["name"], value: row["name"]))
          .toList();
      List<ValueItem> subCategories = results[4]
          .map((row) => ValueItem(label: row["name"], value: row["name"]))
          .toList();

      safePrint("did fetch Filter");
      return [emails, roles, aircrafts, categories, subCategories];
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
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
            side: const BorderSide(color: Colors.black),
          ),
        ),
      ),
      child: const Text('+ Add a document'),
    );
  }
}
