import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

class Document {
  Document({
    required int id,
    required String fileName,
    required bool archived,
    required String email,
    required String subcategory,
    required String category,
    String? aircraft,
    required DateTime createdAt,
  })  : _id = id,
        _fileName = fileName,
        _archived = archived,
        _email = email,
        _subcategory = subcategory,
        _category = category,
        _aircraft = aircraft,
        _createdAt = createdAt;
  Document.fromJSON(Map<String, dynamic> json)
      : _id = json["document_id"] as int,
        _fileName = json["file_name"] as String,
        _archived = intToBool(json["archived"] as int)!,
        _email = json["author"] as String,
        _subcategory = json["sub_category"] as String,
        _category = json["category"] as String,
        _aircraft = json["aircrafts"] as String?,
        _createdAt = DateTime.parse(json["created_at"]);
  final int _id;
  String _fileName;
  final bool _archived;
  final String _email;
  final String _category;
  final String _subcategory;
  final String? _aircraft;
  final DateTime _createdAt;
  int get id => _id;
  String get fileName => _fileName;
  bool get archived => _archived;
  String get author => _email;
  String get subcategory => _subcategory;
  String get category => _category;
  String? get aircraft => _aircraft;
  DateTime get createdAt => _createdAt;
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
      cellFor(subcategory),
      cellFor(category),
      cellFor(aircraft),
      cellFor(archived),
      cellFor(createdAt),
      const DataCell(ActionButtonsWidget())
    ]);
  }

  // can rearrange collumn
  static List<String> columnNames = [
    "File name",
    "Author",
    "Sub category",
    "Category",
    "Aircrafts",
    "Archived",
    "Date",
    "Actions",
  ];

  Future<Uri> getFileUrl() async {
    try {
      String pathStr = "${id}_$fileName";

      final result = await Amplify.Storage.getUrl(
        path: StoragePath.fromString(pathStr),
        options: const StorageGetUrlOptions(
          pluginOptions: S3GetUrlPluginOptions(
            validateObjectExistence: true,
            expiresIn: Duration(days: 1),
          ),
        ),
      ).result;
      debugPrint('url: ${result.url}');
      return result.url;
    } on StorageException catch (e) {
      debugPrint(e.message);
      return Uri();
    }
  }

  Future<void> replaceFile() async {
    String pathStr = "${id}_$fileName";
    String extention = p.extension(fileName);
    // Select a file from the device
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: false,
      // Ensure to get file stream for better performance
      withReadStream: true,
      allowedExtensions: [extention],
    );

    if (result == null) {
      debugPrint('No file selected');
      return;
    }

    final platformFile = result.files.single;
    try {
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          platformFile.readStream!,
          size: platformFile.size,
        ),
        path: StoragePath.fromString(pathStr),
        onProgress: (progress) {
          debugPrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      debugPrint('Successfully uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      debugPrint(e.message);
    }
  }

  Future<void> renameFile(String newFileName) async {
    try {
      String oldPahtStr = "${id}_$fileName";
      String newPathStr = "${id}_$newFileName";
      final copyResult = await Amplify.Storage.copy(
        source: StoragePath.fromString(oldPahtStr),
        destination: StoragePath.fromString(newPathStr),
      ).result;
      debugPrint('Copied file: ${copyResult.copiedItem.path}');
      final removeResult = await Amplify.Storage.remove(
        path: StoragePath.fromString(newPathStr),
      ).result;
      debugPrint('Removed file: ${removeResult.removedItem.path}');
      _fileName = newFileName;
    } on StorageException catch (e) {
      debugPrint(e.message);
    }
  }
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
        'authors': '/staff',
        // filter by roles could be more complex then it should
        // 'roles': '/roles',
        'aircrafts': '/aircrafts',
        'categories': '/categories',
        'sub-categories': '/sub-categories',
      };

  Map<String, String> get sqlColumns => {
        'File Name': 'file_name',
        'Author': 'email',
        'Archived': "archived",
        'Category': 'category',
        'Sub-category': 'sub_category',
        'Aircrafts': 'aircrafts',
        'Date': 'created_at',
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
            SortBy(
              filters: _filters,
              refreshDatasource: refreshDatasource,
              sqlColumns: sqlColumns,
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

class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.remove_red_eye_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.archive_outlined)),
      ],
    );
  }
}
