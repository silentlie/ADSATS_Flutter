import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';

class Document {
  Document({
    required int id,
    required String fileName,
    required bool archived,
    required String email,
    required DateTime createdAt,
    required String subcategory,
    required String category,
    String? aircraft,
  })  : _id = id,
        _fileName = fileName,
        _archived = archived,
        _email = email,
        _createdAt = createdAt,
        _subcategory = subcategory,
        _category = category,
        _aircraft = aircraft;
  Document.fromJSON(Map<String, dynamic> json)
      : _id = json["document_id"] as int,
        _fileName = json["file_name"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _email = json["author"] as String,
        _createdAt = DateTime.parse(json["created_at"]),
        _subcategory = json["sub_category"] as String,
        _category = json["category"] as String,
        _aircraft = json["aircrafts"] as String?;
  final int _id;
  final String _fileName;
  final bool _archived;
  final String _email;
  final DateTime _createdAt;
  final String _category;
  final String _subcategory;
  final String? _aircraft;

  int get id => _id;
  String get fileName => _fileName;
  bool get archived => _archived;
  String get author => _email;
  DateTime get createdAt => _createdAt;
  String get subcategory => _subcategory;
  String get category => _category;
  String? get aircraft => _aircraft;

  String get archivedStatus => _archived == true ? 'Archived' : "Active";

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(cells: <DataCell>[
      cellFor(fileName),
      cellFor(author),
      cellFor(archived),
      cellFor(createdAt),
      cellFor(subcategory),
      cellFor(category),
      cellFor(aircraft),
      cellFor("actions"),
    ]);
  }

  // can rearrange collumn
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
  get showCheckBox => false;

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
      Map<String, String> queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
      queryParameters.addAll(filter.toJSON());
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/documents',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      _totalRecords = rawData["total_records"];
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);

      _documents = [for (var row in rowsData) Document.fromJSON(row)];
      debugPrint(_documents.length.toString());
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
    return _documents.map((document) {
      return document.toDataRow();
    }).toList();
  }

  Map<String, String> get filterEndpoints => {
        'author': '/staff',
        // filter by roles could be more complex then it should
        // 'roles': '/roles',
        'aircrafts': '/aircrafts',
        'categories': '/categories',
        'sub-categories': '/sub-categories',
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
        child: Row(
          children: [
            const AddADocumentButton(),
            const SizedBox(
              width: 10,
            ),
            FilterBy(
              filters: _filters,
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
              filters: _filters,
              refreshDatasource: refreshDatasource,
            ),
          ],
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
      // testing visual
      // style: ButtonStyle(
      //   shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      //     RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(8),
      //       side: const BorderSide(color: Color(0xFF05ABC4)),
      //     ),
      //   ),
      // ),
      child: const Text('+ Add a document'),
    );
  }
}
