part of 'document_class.dart';

class ChooseAircraft extends StatelessWidget {
  const ChooseAircraft({super.key, required this.initialValue});
  final List<dynamic> initialValue;
  @override
  Widget build(BuildContext context) {
    DocumentNotifier newDocument = Provider.of<DocumentNotifier>(context);
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
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
      items: authNotifier.aircraftCache.entries.map(
        (entry) {
          return MultiSelectItem(
            entry.key,
            entry.value,
          );
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
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    newDocument.results['subcategory'] =
        authNotifier.subcategoriesCache.keys.firstOrNull;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu(
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
        dropdownMenuEntries: authNotifier.subcategoriesCache.entries.map(
          (entry) {
            return DropdownMenuEntry(
              value: entry.key,
              label: entry.value,
            );
          },
        ).toList(),
        enableSearch: true,
        enabled: true,
        hintText: "Choose a subcategory",
        menuHeight: 200,
        label: const Text("Choose a subcategory"),
        leadingIcon: const Icon(Icons.search),
        onSelected: (value) {
          newDocument.results['subcategory'] = value!;
        },
        initialSelection: authNotifier.subcategoriesCache.keys.firstOrNull,
        expandedInsets: EdgeInsets.zero,
      ),
    );
  }
}
