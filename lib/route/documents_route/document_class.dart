import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';

part 'documents_api.dart';

class Document {
  Document({
    int? id,
    String? fileName,
    bool? archived,
    String? email,
    String? subcategory,
    String? category,
    String? aircraft,
    DateTime? createdAt,
  });
  Document.fromJSON(Map<String, dynamic> json)
      : id = json["document_id"] as int,
        fileName = json["file_name"] as String,
        archived = intToBool(json["archived"] as int)!,
        author = json["author"] as String,
        subcategory = json["sub_category"] as String,
        category = json["category"] as String,
        aircrafts = json["aircrafts"] as String?,
        createdAt = DateTime.parse(json["created_at"]);
  Document.copy(this.fileName, Document anotherDocument) {
    author = anotherDocument.author;
    subcategory = anotherDocument.subcategory;
    aircrafts = anotherDocument.aircrafts;
  }
  int? id;
  String? fileName;
  bool? archived;
  String? author;
  String? subcategory;
  String? category;
  String? aircrafts;
  DateTime? createdAt;

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  Map<String, String> toJSON() {
    Map<String, String> temp = {};
    if (id != null) {
      temp["id"] = id!.toString();
    }
    temp["file_name"] = fileName!;
    temp["email"] = author!;
    temp["subcategory"] = subcategory!;
    if (aircrafts != null) {
      temp["aircrafts"] = aircrafts.toString();
    }
    return temp;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(
      cells: <DataCell>[
        cellFor(fileName),
        cellFor(author),
        cellFor(subcategory),
        cellFor(category),
        cellFor(aircrafts),
        cellFor(archived),
        cellFor(createdAt),
        DataCell(
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.remove_red_eye_outlined),
                tooltip: 'View',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.archive_outlined),
                tooltip: 'Archive',
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
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
    assert(fileName != null);
    String pathStr = "${id}_$fileName";
    String extention = p.extension(fileName!);
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
      fileName = newFileName;
    } on StorageException catch (e) {
      debugPrint(e.message);
    }
  }
}
