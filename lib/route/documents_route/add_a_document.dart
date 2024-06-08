import 'dart:convert';

import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/documents_route/document_class.dart';
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
    NewDocument newDocument = Provider.of<NewDocument>(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
        Row(
          children: [
            SearchAuthorWidget(
              customClass: newDocument,
            ),
            const CategoriesWidget(),
          ],
        ),
        const Divider(),
        const DropFileWidget(),
        const Divider(),
        Row(
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
                            newDocument.filePickerResult?.files.forEach(
                              (element) {
                                debugPrint(element.name);
                              },
                            );
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
        )
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
              width: 600,
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
        Wrap(
          children: newDocument.filePickerResult?.files.map(
                (file) {
                  return Chip(label: Text(file.name));
                },
              ).toList() ??
              [],
        )
      ],
    );
  }
}

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key});

  static Map<String, String> filterEndpoints = {
    'sub_category': '/sub-categories',
    'aircrafts': '/aircrafts',
  };

  Future<Map<String, List<String>>> fetchFilter(
      Map<String, String>? filterEndpoints) async {
    try {
      // Function to make API requests and return the parsed response
      Future<List<String>> fetchData(String endpoint) async {
        RestOperation restOperation =
            Amplify.API.get(endpoint, apiName: 'AmplifyFilterAPI');
        AWSHttpResponse response = await restOperation.response;
        String jsonStr = response.decodeBody();
        // Map<String, dynamic> rawData = jsonDecode(jsonStr);
        return List<String>.from(jsonDecode(jsonStr));
      }

      // Perform all fetches concurrently
      List<Future<List<String>>> futures =
          filterEndpoints?.values.map(fetchData).toList() ?? [];

      List<List<String>> results = await Future.wait(futures);

      List<String> keys = filterEndpoints?.keys.toList() ?? [];
      Map<String, List<String>> mappedResults =
          Map.fromIterables(keys, results);
      // Process the results
      safePrint("did fetch Filter");
      return mappedResults;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    NewDocument newDocument = Provider.of<NewDocument>(context);
    return FutureBuilder(
      future: fetchFilter(filterEndpoints),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading widget can be customise
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // can make it into a error widget for more visualise
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          // if data is fetch successfully
          Map<String, List<String>> filterData = snapshot.data!;
          List<Widget> children = [];
          filterData.forEach(
            (key, value) {
              if (key == 'sub_category') {
                children.add(
                  DropdownMenu(
                    dropdownMenuEntries: value.map(
                      (item) {
                        return DropdownMenuEntry(value: item, label: item);
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
                );
              }
              if (key == 'aircrafts') {
                children.add(Container(
                  // sized of multi select
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: MultiSelectDialogField(
                    items: value.map(
                      (item) {
                        return MultiSelectItem(item, item);
                      },
                    ).toList(),
                    onConfirm: (selectedItem) {
                      newDocument.aircrafts =
                          List<String>.from(selectedItem).join(',');
                    },
                    buttonText: const Text("Choose aircrafts (Optional)"),
                    searchable: true,
                    // size of dialog after click each filter
                    dialogHeight: 714,
                    dialogWidth: 400,
                    // can be specify based on ThemeData
                    itemsTextStyle: const TextStyle(color: Colors.amber),
                    selectedItemsTextStyle: const TextStyle(color: Colors.blue),
                    cancelText: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.amber),
                    ),
                    confirmText: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.blue),
                    ),
                    chipDisplay: MultiSelectChipDisplay(
                      scroll: true,
                      scrollBar: HorizontalScrollBar(isAlwaysShown: true),
                    ),
                  ),
                ));
              }
            },
          );
          return Row(
            children: children,
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}

class NewDocument extends ChangeNotifier {
  String? fileName;
  String? author;
  String? subcategory;
  String? aircrafts;
  FilePickerResult? filePickerResult;
}
