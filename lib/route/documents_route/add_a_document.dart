import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/amplify/s3_storage.dart';

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
        const FileDetails(),
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
          author: author,
        ),
      ],
    );
  }
}
