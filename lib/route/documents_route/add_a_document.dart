import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class AddADocument extends StatelessWidget {
  const AddADocument({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return NewDocument();
      },
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1536),
          child: const SingleChildScrollView(
            child: Card(
              elevation: 20,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: AddADocumentBody(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddADocumentBody extends StatelessWidget {
  const AddADocumentBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              child: const Text(
                'Add a Document',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        const DetailsWidget(),
        const Divider(),
        const DropFileWidget(),
        const Divider(),
        const ButtonsRow(),
      ],
    );
  }
}

class DropFileWidget extends StatefulWidget {
  const DropFileWidget({super.key});

  @override
  State<DropFileWidget> createState() => _DropFileWidgetState();
}

class _DropFileWidgetState extends State<DropFileWidget> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    NewDocument newDocument = Provider.of<NewDocument>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            newDocument.filePickerResult = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.any,
              withData: false,
              // Ensure to get file stream for better performance
              withReadStream: true,
            );
            setState(() {});
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 400,
              height: 300,
              color: colorScheme.inversePrimary,
              padding: const EdgeInsets.all(20),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload,
                      size: 80,
                    ),
                    Text(
                      'Drop files here',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(8),
          child: Wrap(
            runSpacing: 8,
            spacing: 8,
            children: newDocument.filePickerResult?.files.map(
                  (file) {
                    return Chip(label: Text(file.name));
                  },
                ).toList() ??
                [],
          ),
        )
      ],
    );
  }
}

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    NewDocument newDocument = Provider.of<NewDocument>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    List<Widget> children = [
      Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SearchAuthorWidget(
          customClass: newDocument,
        ),
      ),
      DropdownMenu(
        dropdownMenuEntries: authNotifier.subcategories.map(
          (role) {
            return DropdownMenuEntry(value: role, label: role);
          },
        ).toList(),
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
          onConfirm: (selectedItem) {
            newDocument.aircraft = List<String>.from(selectedItem).join(',');
          },
          items: authNotifier.aircraft.map(
            (aircraft) {
              return MultiSelectItem(aircraft, aircraft);
            },
          ).toList(),
        ),
      )
    ];
    return Wrap(
      children: children,
    );
  }
}

class NewDocument extends ChangeNotifier {
  String? author;
  String? subcategory;
  String? aircraft;
  FilePickerResult? filePickerResult;

  Future<void> uploadFile(PlatformFile file) async {
    try {
      String fileName = file.name;
      Map<String, dynamic> body = {
        'file_name': fileName,
        'email': author,
        'subcategory': subcategory,
        'archived': false,
      };
      if (aircraft?.isNotEmpty ?? false) {
        body['aircraft'] = aircraft;
      }
      debugPrint(body.toString());
      final restOperation = Amplify.API.post('/documents',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int documentID = jsonDecode(jsonStr);
      debugPrint("document_id: $documentID");
      String pathStr = "${documentID}_$fileName";
      final result = await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromStream(
          file.readStream!,
          size: file.size,
        ),
        path: StoragePath.fromString(pathStr),
        onProgress: (progress) {
          debugPrint('Fraction completed: ${progress.fractionCompleted}');
        },
      ).result;
      debugPrint('Successfully uploaded file: ${result.uploadedItem.path}');
    } on StorageException catch (e) {
      debugPrint(e.message);
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void uploadFiles() {
    for (PlatformFile file in filePickerResult!.files) {
      uploadFile(file);
    }
  }
}

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    NewDocument newDocument = Provider.of<NewDocument>(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.go('/documents');
          },
          label: const Text('Cancel'),
          icon: Icon(
            Icons.mail,
            color: colorScheme.onSecondary,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {
            bool validate = newDocument.author != null &&
                newDocument.subcategory != null &&
                newDocument.filePickerResult != null;
            if (!validate) {
              return;
            }
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  actions: [
                    // cancel
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('Cancel'),
                    ),
                    // apply
                    TextButton(
                      onPressed: () {
                        newDocument.uploadFiles();
                        Navigator.pop(context, 'Apply');
                        context.go('/documents');
                      },
                      child: const Text('Apply'),
                    )
                  ],
                );
              },
            );
          },
          style: ButtonStyle(
            // Change button background color
            backgroundColor:
                WidgetStateProperty.all<Color>(colorScheme.secondary),
          ),
          label: Text(
            'Upload Files',
            style: TextStyle(color: colorScheme.onSecondary),
          ),
          icon: Icon(
            Icons.mail,
            color: colorScheme.onSecondary,
          ),
        ),
      ],
    );
  }
}
