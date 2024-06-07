import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

part 'documents_api.dart';
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
    return DataRow(
      cells: <DataCell>[
        cellFor(fileName),
        cellFor(author),
        cellFor(subcategory),
        cellFor(category),
        cellFor(aircraft),
        cellFor(archived),
        cellFor(createdAt),
        DataCell(
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.archive_outlined)),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.delete_outline)),
            ],
          ),
        ),
      ],
    );
  }

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