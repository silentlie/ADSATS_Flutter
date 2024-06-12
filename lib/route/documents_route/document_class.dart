import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/documents_route/add_a_document.dart';
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
        subcategory = json["subcategory"] as String,
        category = json["category"] as String,
        aircraft = json["aircraft"] as String?,
        createdAt = DateTime.parse(json["created_at"]);
  Document.copy(this.fileName, Document anotherDocument) {
    author = anotherDocument.author;
    subcategory = anotherDocument.subcategory;
    aircraft = anotherDocument.aircraft;
  }
  int? id;
  String? fileName;
  bool? archived;
  String? author;
  String? subcategory;
  String? category;
  String? aircraft;
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
    if (aircraft != null) {
      temp["aircraft"] = aircraft.toString();
    }
    return temp;
  }

  // can rearrange collumn
  DataRow toDataRow() {
    return DataRow(
      cells: <DataCell>[
        cellFor(fileName),
        // cellFor(author),
        cellFor(subcategory),
        cellFor(category),
        cellFor(aircraft),
        cellFor(archived),
        cellFor(createdAt),
        DataCell(
          Builder(builder: (context) {
            AuthNotifier authNotifier =
                Provider.of<AuthNotifier>(context, listen: false);
            List<Widget> children = [
              IconButton(
                onPressed: () async {
                  Uri genUrl = await getFileUrl();
                  launchUrl(genUrl);
                },
                icon: const Icon(Icons.remove_red_eye_outlined),
                tooltip: 'View',
              ),
            ];
            if (authNotifier.isAdmin || authNotifier.isEditor) {
              children.addAll([
                IconButton(
                  onPressed: () {
                    showChangeDocumentDetails(context);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () {
                    archive();
                  },
                  icon: const Icon(Icons.archive_outlined),
                  tooltip: 'Archive',
                ),
              ]);
            }
            if (authNotifier.isAdmin) {
              children.add(
                IconButton(
                  onPressed: () {
                    delete();
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            );
          }),
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

  void showChangeDocumentDetails(
    BuildContext context,
  ) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    String newFileName = fileName!;
    final RegExp fileNameRegExp =
        RegExp(r"""^[^~)(!'*<>:;,?"*|/]+\.[A-Za-z]{2,4}$""");
    NewDocument newDocument = NewDocument();
    newDocument.subcategory = subcategory;
    List<Widget> detailsWidgets = [

      Container(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'File Name',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter file name';
            } else if (!fileNameRegExp.hasMatch(value)) {
              return 'Please enter a valid file name';
            }
            return null;
          },
          onSaved: (value) {
            fileName = value!;
          },
        ),
      ),
      if (authNotifier.isAdmin)
        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.only(bottom: 8),
          child: SearchAuthorWidget(
            customClass: newDocument,
          ),
        ),
      DropdownMenu(
        dropdownMenuEntries: authNotifier.subcategories.map(
          (subcategory) {
            return DropdownMenuEntry(value: subcategory, label: subcategory);
          },
        ).toList(),
        initialSelection: subcategory,
        enableSearch: true,
        enabled: true,
        hintText: "Choose a sub-category",
        menuHeight: 200,
        label: const Text("Choose a sub-category"),
        leadingIcon: const Icon(Icons.search),
        onSelected: (value) {
          newDocument.subcategory = value!;
        },
      ),
      Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: MultiSelect(
          buttonText: const Text("Add aircraft(not working at the moment)"),
          title: const Text("Add aircraft(not working at the moment)"),
          onConfirm: (selectedItem) {
            newDocument.aircraft = List<String>.from(selectedItem).join(',');
          },
          items: authNotifier.aircraft.map(
            (aircraft) {
              return MultiSelectItem(aircraft, aircraft);
            },
          ).toList(),
          initialValue:
              aircraft?.split(',').map((item) => item.trim()).toList() ?? [],
        ),
      )
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: detailsWidgets,
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
              onPressed: () => replaceFile(),
              child: const Text('Replace File'),
            ),
            // apply
            TextButton(
              // apply edit
              onPressed: () {
                if (newDocument.subcategory != null &&
                    formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  newDocument.author ??= authNotifier.email;
                  changeDocumentDetails(newFileName, newDocument);
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

  Future<void> changeDocumentDetails(
      String fileName, NewDocument newDocument) async {
    try {
      Map<String, dynamic> body = {
        'document_id': id,
        'file_name': fileName,
        'email': newDocument.author,
        'subcategory': newDocument.subcategory,
      };
      if (newDocument.aircraft?.isNotEmpty ?? false) {
        body['aircraft'] = newDocument.aircraft;
      }
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/documents',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      archived = !archived!;
      debugPrint("archive: $rawData");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> replaceFile() async {
    assert(fileName != null);
    String pathStr = "${id}_$fileName";
    String extention = p.extension(fileName!).substring(1);
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
        'archived': !archived!,
        'document_id': id,
      };
      debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/documents',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int rawData = jsonDecode(jsonStr);
      archived = !archived!;
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
      debugPrint(body.toString());
      final restOperation = Amplify.API.delete('/documents',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

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
