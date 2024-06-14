part of 'document_class.dart';

class ChooseAircraft extends StatelessWidget {
  const ChooseAircraft({super.key, required this.initialValue});
  final List<dynamic> initialValue;
  @override
  Widget build(BuildContext context) {
    DocumentNotifier newDocument = Provider.of<DocumentNotifier>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    return MultiSelect(
      buttonText: const Text("Add aircraft"),
      title: const Text("Add aircraft"),
      onConfirm: (selectedItem) {
        if (selectedItem.isEmpty) {
          newDocument.results.remove('aircraft');
        }
        newDocument.results['aircraft'] =
            List<String>.from(selectedItem).join(',');
      },
      items: authNotifier.aircraft.map(
        (aircraft) {
          return MultiSelectItem(aircraft, aircraft);
        },
      ).toList(),
      initialValue: const [],
    );
  }
}

class ChooseCategory extends StatelessWidget {
  const ChooseCategory({super.key});

  @override
  Widget build(BuildContext context) {
    DocumentNotifier newDocument = Provider.of<DocumentNotifier>(context);
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    newDocument.results['subcategory'] = authNotifier.subcategories[0];
    return DropdownMenu(
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
        newDocument.results['subcategory'] = value!;
      },
      initialSelection: authNotifier.subcategories[0],
    );
  }
}
