import 'dart:convert';

import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/documents_route/document_class.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/amplify/s3_storage.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddADocument extends StatelessWidget {
  const AddADocument({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

class AddADocumentBody extends StatelessWidget {
  const AddADocumentBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Document newDocument = Document();
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
            CategoriesWidget(
              newDocument: newDocument,
            ),
          ],
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Upload File',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const DropFileWidget(),
        const UploadButton(),
      ],
    );
  }
}

// TODO: change to multiple documents, pick files button and upload button are seprate

class UploadButton extends StatelessWidget {
  const UploadButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                actions: [
                  // cancel
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Okay'),
                    child: Text(
                      'Okay',
                      style: TextStyle(color: colorScheme.onSecondary),
                    ),
                  ),
                ],
                content: const Text(
                  'Upload successful',
                ),
              ),
            );
          },
          child: const Text('Upload document')),
    );
  }
}

class DropFileWidget extends StatelessWidget {
  const DropFileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        await uploadImage();
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
    );
  }
}

class FileDetails extends StatelessWidget {
  const FileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    String author = "";
    return Wrap(
      children: [
        SearchAuthorWidget(
          customClass: author,
        ),
      ],
    );
  }
}

class CategoriesWidget extends StatelessWidget {
  const CategoriesWidget({super.key, required this.newDocument});
  final Document newDocument;

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
