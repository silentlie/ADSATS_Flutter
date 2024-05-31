import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

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
  static bool intToBool(int value) {
    return value != 0;
  }
}

class DocumentAPI extends DataTableSourceAsync {
  DocumentAPI();

  List<String> get columnNames => [
        "Name",
        "Author",
        "Archived",
        "Date",
        "Last Modified",
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
  final CustomTableFilter _filters = CustomTableFilter();
  Future<void> fetchData(int startIndex, int count,
      [CustomTableFilter? filter]) async {
    try {
      final queryParameters = {
        "offset": startIndex.toString(),
        "limit": count.toString()
      };
      if (filter != null) {}
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
      safePrint("did fetch Data");
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
    _documents;

    return _documents.map((document) {
      return DataRow(cells: <DataCell>[
        cellFor(document.fileName),
        cellFor(document.email),
        cellFor(document.archived),
        cellFor(document.dateCreated),
        cellFor(document.lastModified),
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
      await fetchData(startIndex, count, _filters);
      AsyncRowsResponse response = AsyncRowsResponse(totalRecords, rows);
      return response;
    } on Error catch (e) {
      safePrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget get header {
    return HeaderWidget(
        filters: _filters, refreshDatasource: refreshDatasource);
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

class HeaderWidget extends StatelessWidget {
  HeaderWidget(
      {super.key, required this.filters, required this.refreshDatasource});

  final CustomTableFilter filters;
  final Function refreshDatasource;
  final TextEditingController _searchController = TextEditingController();

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
        SearchBar(
          constraints: const BoxConstraints(
            maxWidth: 360,
          ),
          controller: _searchController,
          leading: const Icon(Icons.search),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              _searchController.text = value;
              filters.search = value;
              refreshDatasource();
            } else {
              filters.search = null;
              refreshDatasource();
            }
          },
        ),
        const SizedBox(
          width: 10,
        ),
      ],
    );
  }
}

class FilterBy extends StatefulWidget {
  const FilterBy(
      {super.key, required this.filters, required this.refreshDatasource});
  final CustomTableFilter filters;
  final Function refreshDatasource;
  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  final MutableDateTimeRange _mutableDateTimeRange = MutableDateTimeRange();

  List<String> subcategories = [];

  List<String> categories = [];

  List<String> roles = [];

  List<String> emails = [];

  List<String> aircrafts = [];

  Future<List<Map<String, dynamic>>> fetchData(
      String endpoint, String apiName) async {
    var queryParameters = {"offset": "0", "limit": "5"};
    var restOperation = Amplify.API
        .get(endpoint, apiName: apiName, queryParameters: queryParameters);
    var response = await restOperation.response;
    String jsonStr = response.decodeBody();
    Map<String, dynamic> rawData = jsonDecode(jsonStr);
    return List<Map<String, dynamic>>.from(rawData["rows"]);
  }

  Future<void> fetchFilters() async {
    try {
      var futures = <Future>[
        fetchData('/crews', 'AmplifyCrewAPI'),
        fetchData('/roles', 'AmplifyCrewAPI'),
        fetchData('/aircrafts', 'AmplifyCrewAPI')
      ];
      var results = await Future.wait(futures);
      // Process the results
      emails = results[0].map((row) => row["email"] as String).toList();
      roles = results[1].map((row) => row["role"] as String).toList();
      aircrafts = results[2].map((row) => row["name"] as String).toList();
      safePrint("did fetch Filter");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MultiSelectDropDown(
                  onOptionSelected: (selectedOptions) {},
                  options: const <ValueItem>[],
                  hint: "Crew's emails",
                  searchEnabled: true,
                ),
                DateTimeRangePicker(
                  mutableDateTimeRange: _mutableDateTimeRange,
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  widget.refreshDatasource();
                  Navigator.pop(context, 'Apply');
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
      child: const Text("Filter By"),
    );
  }
}
