part of 'abstract_data_table_async.dart';

class FilterBy extends StatelessWidget {
  FilterBy({
    super.key,
    required this.filters,
    required this.refreshDatasource,
    this.filterByAuthors = false,
    this.filterByAircraft = false,
    this.filterByRoles = false,
    this.filterByCategories = false,
    this.filterBySubcategories = false,
    this.filterByNoticeTypes = false,
    this.filterByArchived = false,
    this.filterByCreatedAt = false,
    this.filterByDeadlineAt = false,
  }) {
    assert((filterByCategories == false &&
            filterByCategories == false &&
            filterByNoticeTypes == true) ||
        (filterByCategories == true &&
            filterByCategories == true &&
            filterByNoticeTypes == false) ||
        (filterByCategories == false &&
            filterByCategories == false &&
            filterByNoticeTypes == false));
  }

  final CustomTableFilter filters;
  final Function refreshDatasource;
  final bool filterByAuthors;
  final bool filterByAircraft;
  final bool filterByRoles;
  final bool filterByCategories;
  final bool filterBySubcategories;
  final bool filterByNoticeTypes;
  final bool filterByArchived;
  final bool filterByCreatedAt;
  final bool filterByDeadlineAt;

  bool? strToBool(String? str) {
    if (str == null) {
      return null;
    }
    return str.toLowerCase() == 'true';
  }

  static List<String> noticeTypes = [
    'Notice to crew',
    'Safety notice',
    'Hazard report',
    'BCAA report',
  ];

  List<Widget> getFilterContent(
      BuildContext context, Map<String, dynamic> filterResult) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return [
      if (filterByAuthors)
        MultiSelect(
          buttonText: const Text("Filter by authors"),
          title: const Text("Filter by authors"),
          items: authNotifier.staffCache.entries.map(
            (entry) {
              return MultiSelectItem(
                entry.key,
                entry.value,
              );
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["authors"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResults["authors"] ?? [],
        ),
      if (filterByAircraft)
        MultiSelect(
          buttonText: const Text("Filter by aircraft"),
          title: const Text("Filter by aircraft"),
          items: authNotifier.aircraftCache.entries.map(
            (entry) {
              return MultiSelectItem(
                entry.key,
                entry.value,
              );
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["aircraft"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResults["aircraft"] ?? [],
        ),
      if (filterByRoles)
        MultiSelect(
          buttonText: const Text("Filter by roles"),
          title: const Text("Filter by roles"),
          items: authNotifier.rolesCache.entries.map(
            (entry) {
              return MultiSelectItem(
                entry.key,
                entry.value,
              );
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["roles"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResults["roles"] ?? [],
        ),
      if (filterByCategories)
        MultiSelect(
          buttonText: const Text("Filter by categories"),
          title: const Text("Filter by categories"),
          items: authNotifier.categoriesCache.entries.map(
            (entry) {
              return MultiSelectItem(
                entry.key,
                entry.value,
              );
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["categories"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResults["categories"] ?? [],
        ),
      if (filterBySubcategories)
        MultiSelect(
          buttonText: const Text("Filter by subcategories"),
          title: const Text("Filter by subcategories"),
          items: authNotifier.subcategoriesCache.entries.map(
            (entry) {
              return MultiSelectItem(
                entry.key,
                entry.value,
              );
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["subcategories"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResults["subcategories"] ?? [],
        ),
      if (filterByNoticeTypes)
        MultiSelect(
          buttonText: const Text("Filter by notice types"),
          title: const Text("Filter by notice types"),
          items: noticeTypes.map(
            (type) {
              return MultiSelectItem(type, type);
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["categories"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResults["categories"] ?? [],
        ),
      if (filterByArchived)
        Container(
          padding: const EdgeInsets.all(8),
          child: DropdownMenu(
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: false, label: "False"),
              DropdownMenuEntry(value: true, label: "True"),
              DropdownMenuEntry(value: null, label: "All"),
            ],
            onSelected: (value) {
              filterResult["archived"] = value;
            },
            initialSelection: filters.filterResults["archived"] as bool?,
            expandedInsets: EdgeInsets.zero,
            requestFocusOnTap: false,
            hintText: "Archived",
            label: const Text(
              "Archived",
            ),
          ),
        ),
      if (filterByCreatedAt)
        Container(
          padding: const EdgeInsets.all(8),
          child: DateTimeRangePicker(
            filterResult: filterResult,
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // result of filter before click apply
    Map<String, dynamic> filterResult = {};
    // filter button, the visual can be customised
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Filter By:'),
              content: Container(
                // max width of filter column
                constraints: const BoxConstraints(maxWidth: 400, minWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: getFilterContent(context, filterResult),
                ),
              ),
              actions: [
                // cancel
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Cancel'),
                  child: const Text('Cancel'),
                ),
                // apply
                TextButton(
                  onPressed: () {
                    filters.filterResults.addAll(filterResult);
                    // refresh table based on filter
                    refreshDatasource();
                    Navigator.pop(context, 'Apply');
                  },
                  child: const Text('Apply'),
                )
              ],
            );
          },
        );
      },
      child: const Text("Filter By"),
    );
  }
}
