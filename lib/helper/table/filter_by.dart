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
    'BCAA pcciremce report',
  ];

  List<Widget> getFilterContent(
      BuildContext context, Map<String, List<String>> filterResult) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    List<Widget> filterContent = [];

    if (filterByAuthors) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by authors"),
          title: const Text("Filter by authors"),
          items: authNotifier.staff.map(
            (staff) {
              return MultiSelectItem(staff, staff);
            },
          ).toList(),
          onConfirm: (selectedOptions) {
            filterResult["authors"] = List<String>.from(selectedOptions);
          },
          initialValue: filters.filterResult["authors"] ?? [],
        ),
      );
    }

    if (filterByAircraft) {
      filterContent.add(
        MultiSelect(
          buttonText: const Text("Filter by aircrafts"),
          title: const Text("Filter by aircrafts"),
          items: authNotifier.aircraft.map(
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
          items: authNotifier.roles.map(
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
          items: authNotifier.categories.map(
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
          items: authNotifier.subcategories.map(
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
