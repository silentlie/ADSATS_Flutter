import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import 'package:adsats_flutter/route/documents_route/filter_by.dart';
import 'package:adsats_flutter/abstract_data_table_async.dart';

class Document {
  Document({
    required int id,
    required String fileName,
    required bool archived,
    required String email,
    required DateTime dateCreated,
    DateTime? lastModified,
    required String subcategory,
    required String category,
    String? aircraft,
  })  : _id = id,
        _fileName = fileName,
        _archived = archived,
        _email = email,
        _dateCreated = dateCreated,
        _lastModified = lastModified,
        _subcategory = subcategory,
        _category = category,
        _aircraft = aircraft;
  Document.fromJSON(Map<String, dynamic> json)
      : _id = json["document_id"] as int,
        _fileName = json["file_name"] as String,
        _archived = intToBool(json["archived"] as int),
        _email = json["email"] as String,
        _dateCreated = DateTime.parse(json["created_at"]),
        _lastModified = DateTime.parse(json["modified_at"]),
        _subcategory = json["subcategory"] as String,
        _category = json["category"] as String,
        _aircraft = json["aircrafts"] as String?;
  final int _id;
  final String _fileName;
  final bool? _archived;
  final String _email;
  final DateTime _dateCreated;
  final DateTime? _lastModified;
  final String _category;
  final String _subcategory;
  final String? _aircraft;

  int get id => _id;
  String get fileName => _fileName;
  bool? get archived => _archived;
  String get email => _email;
  DateTime get dateCreated => _dateCreated;
  DateTime? get lastModified => _lastModified;
  String get subcategory => _subcategory;
  String get category => _category;
  String? get aircraft => _aircraft;

  String get archivedStatus => _archived == true ? 'Archived' : "Active";

  static bool intToBool(int value) {
    return value != 0;
  }
}

class DocumentAPI extends DataTableSourceAsync {
  DocumentAPI();

  List<String> get columnNames => [
        "Name",
        //"Author",
        "Archived",
        "Date",
        //"Last Modified",
        "Sub category",
        "Category",
        "Aircrafts",
        "Actions",
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

  @override
  get showCheckBox => false;
  CustomTableFilter? _filters;
  @override
  CustomTableFilter? get filters => _filters;
  @override
  set filters(CustomTableFilter? newFilters) {
    filters = newFilters;
    refreshDatasource();
  }

  Future<void> fetchData(int startIndex, int count,
      [CustomTableFilter? filter]) async {
    try {
      final restOperation = Amplify.API.get('/documents',
          apiName: 'AmplifyCrewAPI',
          queryParameters: {
            "offset": startIndex.toString(),
            "limit": count.toString()
          });
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
    } on ApiException catch (e) {
      safePrint('GET call failed: $e');
      _totalRecords = 0;
      _documents = [];
    } on Error catch (e) {
      safePrint('Error: $e');
      rethrow;
    }
  }

  List<Document> _documents = [];
  int _totalRecords = 0;
  @override
  int get totalRecords => _totalRecords;

  List<DataRow> get rows {
    _documents;

    return _documents.map((document) {
      return DataRow(cells: <DataCell>[
        cellFor(document.fileName),
        //cellFor(document.email),
        //cellFor(document.archived),
        DataCell(
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Container(
                width: 75,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  color: document.archived!
                      ? Colors.grey
                      : theme.colorScheme.primaryContainer,
                ),
                child: Center(
                  child: Text(
                    document.archived! ? "Archived" : "Active",
                    style:
                        TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  ),
                ),
              );
            },
          ),
        ),
        cellFor(document.dateCreated),
        //cellFor(document.lastModified),
        cellFor(document.subcategory),
        cellFor(document.category),
        cellFor(document.aircraft),
        cellFor("actions"),
      ]);
    }).toList();
  }

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    try {
      // implement filtering
      await fetchData(startIndex, count, filters);
      AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
      return response;
    } on Error catch (e) {
      safePrint('Error: $e');
      rethrow;
    }
  }

  final Widget _header = const Row(
    children: [
      Text(
        "Documents",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(
        width: 10,
      ),
      AddADocumentButton(),
      Spacer(),
      SearchTextField(),
      SizedBox(
        width: 10,
      ),
      FilterBy(),
    ],
  );
  @override
  Widget get header => _header;
}

class FilterBy extends StatelessWidget {
  const FilterBy({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => const FilterByAlertDialog()),
        child: const Text("Filter By"));
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 250,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          suffixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
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
