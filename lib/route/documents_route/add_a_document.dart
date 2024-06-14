part of 'document_class.dart';

class AddADocument extends StatelessWidget {
  const AddADocument({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        return DocumentNotifier();
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
    DocumentNotifier newDocument = Provider.of<DocumentNotifier>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
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
        Wrap(
          children: [
            if (authNotifier.isAdmin)
              Container(
                padding: const EdgeInsets.all(8),
                child: SearchAuthorWidget(
                  result: newDocument.results,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(8),
              child: const ChooseCategory(),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: const ChooseAircraft(
                initialValue: [],
              ),
            )
          ],
        ),
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
    DocumentNotifier newDocument = Provider.of<DocumentNotifier>(context);
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

class ButtonsRow extends StatelessWidget {
  const ButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentNotifier newDocument = Provider.of<DocumentNotifier>(context);
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            context.go('/documents');
          },
          label: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () {
            if (newDocument.filePickerResult == null) {
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
