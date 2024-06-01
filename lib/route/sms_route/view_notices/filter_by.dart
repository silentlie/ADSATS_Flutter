import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class FilterBy extends StatefulWidget {
  const FilterBy({super.key});

  @override
  State<FilterBy> createState() => _FilterByState();
}

class _FilterByState extends State<FilterBy> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Filter By:'),
              content: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MultiSelectDialogField(
                      chipDisplay: MultiSelectChipDisplay(
                        scroll: true,
                        scrollBar: HorizontalScrollBar(isAlwaysShown: true),
                      ),
                      items: [
                        MultiSelectItem("Item1", "Item1"),
                        MultiSelectItem("Item2", "Item2"),
                        MultiSelectItem("Item3", "Item3"),
                        MultiSelectItem("Item4", "Item4"),
                        MultiSelectItem("Item5", "Item5"),
                        MultiSelectItem("Item6", "Item6"),
                        MultiSelectItem("Item7", "Item7"),
                      ],
                      itemsTextStyle: const TextStyle(color: Colors.amber),
                      selectedItemsTextStyle:
                          const TextStyle(color: Colors.blue),
                      cancelText: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.amber),
                      ),
                      confirmText: const Text(
                        "Confirm",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onConfirm: (p0) {},
                      searchable: true,
                      dialogHeight: 200,
                      dialogWidth: 200,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, 'Apply');
                    },
                    child: const Text('Apply'))
              ],
            );
          },
        );
      },
      child: const Text("Filter By"),
    );
  }
}
