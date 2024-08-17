import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';

part 'documents_api.dart';
part 'add_a_document.dart';
part 'components.dart';
part 'document_notifier.dart';

class Document {
  Document.fromJSON(Map<String, dynamic> json) {
    id = json["document_id"] as int;
    fileName = json["document_name"] as String;
    archived = intToBool(json["archived"] as int)!;
    staffId = json["staff_id"] as int?;
    subcategory = json["subcategory_id"] as int?;
    roles = json["roles"] as String?;
    aircraft = json["aircraft"] as String?;
    createdAt = DateTime.parse(json["created_at"]);
  }
  late int id;
  late String fileName;
  late bool archived;
  late int? staffId;
  late int? subcategory;
  String? roles;
  String? aircraft;
  late DateTime createdAt;

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  // can rearrange collumn
  DataRow toDataRow(void Function() refreshDatasource) {
    return DataRow(
      cells: <DataCell>[
        cellFor(fileName),
        cellFor(subcategory),
        cellFor(aircraft),
        cellFor(roles),
        cellFor(archived),
        cellFor(createdAt),
        DataCell(
          Builder(builder: (context) {
            AuthNotifier authNotifier =
                Provider.of<AuthNotifier>(context, listen: false);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    Uri genUrl = await getFileUrl();
                    launchUrl(genUrl);
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  tooltip: 'View',
                ),
                if (authNotifier.isAdmin || authNotifier.isEditor)
                  IconButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return changeDocumentDetailsWidget(context);
                        },
                      );
                      refreshDatasource();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: 'Edit',
                  ),
                if (authNotifier.isAdmin || authNotifier.isEditor)
                  IconButton(
                    onPressed: () async {
                      await archive();
                      refreshDatasource();
                    },
                    icon: const Icon(Icons.archive_outlined),
                    tooltip: 'Archive',
                  ),
                if (authNotifier.isAdmin)
                  IconButton(
                    onPressed: () async {
                      await delete();
                      refreshDatasource();
                    },
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete',
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget changeDocumentDetailsWidget(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DocumentNotifier(),
      builder: (context, child) {
        AuthNotifier authNotifier =
            Provider.of<AuthNotifier>(context, listen: false);
        final formKey = GlobalKey<FormState>();
        DocumentNotifier newDocument =
            Provider.of<DocumentNotifier>(context, listen: false);
        return AlertDialog(
          title: const Text("Change Document Details"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SearchAuthorWidget(
                  result: newDocument.results,
                  enabled: authNotifier.isAdmin || authNotifier.isEditor,
                ),
                const ChooseCategory(),
                ChooseAircraft(
                  initialValue: aircraft
                          ?.split(',')
                          .map((item) => item.trim())
                          .toList() ??
                      [],
                )
              ],
            ),
          ),
          actions: [
            // cancel
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            // cancel
            TextButton(
              onPressed: () {
                // TODO: need to fix logic
              },
              child: const Text('Replace File'),
            ),
            // apply
            TextButton(
              // apply edit
              onPressed: () {
                if (newDocument.results['subcategory'] != null &&
                    formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  newDocument.results['author'] ??= authNotifier.email;
                  changeDocumentDetails(newDocument);
                  Navigator.pop(context, 'Apply');
                }
              },
              child: const Text('Apply'),
            )
          ],
        );
      },
    );
  }

  Future<void> changeDocumentDetails(DocumentNotifier newDocument) async {
    try {
      Map<String, dynamic> body = {
        'document_id': id,
      };
      body.addAll(newDocument.results);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/documents',
          apiName: 'AmplifyDocumentsAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      archived = !archived;
      debugPrint("archive: $rawData");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> replaceFile() async {
    // TODO: need to fix logic
    String pathStr = "${id}_$fileName";
    String extention = p.extension(fileName).substring(1);
    // Select a file from the device
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: false,
      // Ensure to get file stream for better performance
      withReadStream: true,
      allowedExtensions: [extention],
    );

    if (result == null) {
      // debugPrint('No file selected');
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
          // debugPrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      debugPrint('Successfully uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      debugPrint(e.message);
    }
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
      // debugPrint('url: ${result.url}');
      return result.url;
    } on StorageException catch (e) {
      debugPrint(e.message);
      return Uri();
    }
  }

  Future<void> renameFile(String newFileName) async {
    try {
      String oldPathStr = "${id}_$fileName";
      String newPathStr = "${id}_$newFileName";
      final copyResult = await Amplify.Storage.copy(
        source: StoragePath.fromString(oldPathStr),
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

  Future<void> archive() async {
    try {
      Map<String, dynamic> body = {
        'archived': !archived,
        'document_id': id,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/documents',
          apiName: 'AmplifyDocumentsAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      archived = !archived;
      debugPrint("archive: $rawData");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      String pathStr = "${id}_$fileName";
      Map<String, dynamic> body = {
        'document_id': id,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/documents',
          apiName: 'AmplifyDocumentsAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      debugPrint("delete: $rawData");
      final removeResult = await Amplify.Storage.remove(
        path: StoragePath.fromString(pathStr),
      ).result;
      debugPrint('Removed file: ${removeResult.removedItem.path}');
    } on StorageException catch (e) {
      debugPrint(e.message);
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
