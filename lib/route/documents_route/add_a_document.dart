import 'package:flutter/material.dart';

class AddADocument extends StatelessWidget {
  const AddADocument({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(child: AddADocumentBody()),
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
        const DropdownRow(),
        const DocumentNameTextField(),
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

class DocumentNameTextField extends StatelessWidget {
  const DocumentNameTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      margin: const EdgeInsets.all(8),
      child: const TextField(
        decoration: InputDecoration(
          label: Text('Name'),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class DropdownRow extends StatelessWidget {
  const DropdownRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: DropdownMenu(
              width: MediaQuery.of(context).size.width * 0.32,
              label: const Text('Sub-Category'),
              dropdownMenuEntries: const <DropdownMenuEntry>[
                DropdownMenuEntry(value: 'Aircraft approvals, certificates and documents', label: 'Aircraft approvals, certificates and documents'),
                DropdownMenuEntry(value: 'Aircraft manuals', label: 'Aircraft manuals'),
                DropdownMenuEntry(value: 'Audit program', label: 'Audit program'),
                DropdownMenuEntry(value: 'BCAA aircraft occurrence reports', label: 'BCAA aircraft occurrence reports'),
                DropdownMenuEntry(value: 'BCAA audits', label: 'BCAA audits'),
                DropdownMenuEntry(value: 'Change management', label: 'Change management'),
                DropdownMenuEntry(value: 'Fatigue management', label: 'Fatigue management'),
                DropdownMenuEntry(value: 'Ground training', label: 'Ground training'),
                DropdownMenuEntry(value: 'Licence and approvals', label: 'Licence and approvals'),
                DropdownMenuEntry(value: 'Safety review board', label: 'Safety review board'),
                DropdownMenuEntry(value: 'Purchase orders', label: 'Purchase orders'),
                DropdownMenuEntry(value: 'Safety notice', label: 'Safety notice'),
                DropdownMenuEntry(value: 'Notice to crew', label: 'Notice to crew'),
                DropdownMenuEntry(value: 'Hazard notice', label: 'Hazard notice'),
                DropdownMenuEntry(value: 'HR documents', label: 'HR documents'),
                DropdownMenuEntry(
                  value: '+ Add a sub-category', 
                  label: '+ Add a sub-category',
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: DropdownMenu(
              width: MediaQuery.of(context).size.width * 0.32,
              label: const Text('Plane (optional)'),
              dropdownMenuEntries: const <DropdownMenuEntry>[
                DropdownMenuEntry(value: 'All', label: 'All'),
                DropdownMenuEntry(
                    value: 'Aircraft 1', label: 'Aircraft 1'),
                DropdownMenuEntry(
                    value: 'Aircraft 2', label: 'Aircraft 2')
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                label: const Text('User'),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search), 
                  onPressed: () {
                  
                },)
              ),
            )
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
          onPressed: () {}, child: const Text('Upload document')),
    );
  }
}

class DropFileWidget extends StatelessWidget {
  const DropFileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 600,
      height: 300,
      color: colorScheme.onSurface,
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
            )
          ],
        ),
      ),
    );
  }
}
