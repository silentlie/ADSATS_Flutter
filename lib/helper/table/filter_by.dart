part of 'abstract_data_table_async.dart';

class FilterBy extends StatelessWidget {
  FilterBy({
    super.key,
    required this.filters,
    required this.refreshDatasource,
    this.filterByAuthors = false,
    this.filterByAircrafts = false,
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
  final bool filterByAircrafts;
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
    'BCAA pcciremce report',
  ];

  List<Widget> getFilterContent(
      BuildContext context, Map<String, List<String>> filterResult) {
    AuthNotifier staff = Provider.of<AuthNotifier>(context);
    List<Widget> filterContent = [];

    if (filterByAuthors) {
      filterContent.add(
        MultiSelect(
          buttonText:
              const Text("Filter by authors(not working at the moment)"),
          title: const Text("Filter by authors(not working at the moment)"),
          items: const [
            // need fetch data from api
          ],
          onConfirm: (selectedOptions) {
            filterResult["authors"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResult["authors"] ?? [],
        ),
      );
    }

    if (filterByAircrafts) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by aircrafts"),
          title: const Text("Filter by aircrafts"),
          items: staff.aircrafts.map(
            (aircraft) {
              return MultiSelectItem(aircraft, aircraft);
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["aircrafts"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResult["aircrafts"] ?? [],
        ),
      );
    }

    if (filterByRoles) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by roles"),
          title: const Text("Filter by roles"),
          items: staff.roles.map(
            (role) {
              return MultiSelectItem(role, role);
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["roles"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResult["roles"] ?? [],
        ),
      );
    }

    if (filterByCategories) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by categories"),
          title: const Text("Filter by categories"),
          items: staff.categories.map(
            (category) {
              return MultiSelectItem(category, category);
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["categories"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResult["categories"] ?? [],
        ),
      );
    }

    if (filterBySubcategories) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by subcategories"),
          title: const Text("Filter by subcategories"),
          items: staff.subcategories.map(
            (subcategory) {
              return MultiSelectItem(subcategory, subcategory);
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["subcategories"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResult["subcategories"] ?? [],
        ),
      );
    }

    if (filterByNoticeTypes) {
      filterContent.add(
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
          initialValue: filters.filterResult["categories"] ?? [],
        ),
      );
    }

    if (filterByArchived) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by archived"),
          title: const Text("Filter by archived"),
          items: [
            MultiSelectItem(true, "True"),
            MultiSelectItem(false, "False")
          ],
          onConfirm: (selectedOptions) {
            if (selectedOptions.length != 2) {
              filterResult["archived"] = selectedOptions
                  .map((boolValue) => boolValue.toString())
                  .toList();
            } else {
              filterResult["archived"] = [];
            }
          },
          initialValue: filters.filterResult["archived"]?.map(
                (str) {
                  switch (str) {
                    case 'true':
                      return true;
                    case 'false':
                      return false;
                    default:
                      return null;
                  }
                },
              ).toList() ??
              [false],
        ),
      );
    }
    if (filterByCreatedAt) {
      filterContent.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DateTimeRangePicker(
            filterResult: filterResult,
          ),
        ),
      );
    }
    return filterContent;
  }

  @override
  Widget build(BuildContext context) {
    // result of filter before click apply
    Map<String, List<String>> filterResult = {};
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
                    filters.filterResult.addAll(filterResult);
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

class MultiSelect extends StatelessWidget {
  const MultiSelect({
    super.key,
    this.buttonText,
    this.initialValue = const [],
    required this.onConfirm,
    this.title,
    required this.items,
  });
  final Text? buttonText;
  final List<MultiSelectItem<dynamic>> items;
  final List<dynamic> initialValue;
  final void Function(List<dynamic>) onConfirm;
  final Widget? title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MultiSelectDialogField(
        buttonText: buttonText,
        items: items,
        initialValue: initialValue,
        // send selected item to filterResult
        onConfirm: onConfirm,
        title: title,
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
    );
  }
}
