import 'package:adsats_flutter/route/settings_route/categories/category_class.dart';
import 'package:adsats_flutter/route/settings_route/subcategories/subcategory_class.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:adsats_flutter/route/settings_route/aircrafts/aircraft_class.dart';
import 'package:adsats_flutter/route/settings_route/staff/staff_class.dart';
import 'package:adsats_flutter/route/settings_route/roles/role_class.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  final List<NavigationRailDestination> _navigationRailDestinations = [
    const NavigationRailDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: Text("Crews"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.airlines_outlined),
      selectedIcon: Icon(Icons.airlines),
      label: Text("Aircrafts"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: Text("Roles"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: Text("Categories"),
    ),
    const NavigationRailDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: Text("Subcategories"),
    ),
  ];
  final List<NavigationDestination> _navigationDestinations = [
    const NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: "Crews",
    ),
    const NavigationDestination(
      icon: Icon(Icons.airlines_outlined),
      selectedIcon: Icon(Icons.airlines),
      label: "Aircrafts",
    ),
    const NavigationDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: "Roles",
    ),
    const NavigationDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: "Categories",
    ),
    const NavigationDestination(
      icon: Icon(Icons.groups_outlined),
      selectedIcon: Icon(Icons.groups),
      label: "Subcategories",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      PaginatedDataTableAsync(StaffApi()),
      PaginatedDataTableAsync(AircraftsAPI()),
      PaginatedDataTableAsync(RolesAPI()),
      PaginatedDataTableAsync(CategoriesApi()),
      PaginatedDataTableAsync(SubcategoriesApi()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 1000) {
          // https://api.flutter.dev/flutter/material/NavigationBar-class.html
          return Column(
            children: [
              Expanded(
                child: Center(
                    child: Container(
                  constraints: const BoxConstraints(maxWidth: 1532),
                  child: _pages[_selectedIndex],
                )),
              ),
              SafeArea(
                child: NavigationBar(
                  onDestinationSelected: (value) {
                    setState(() {
                      _selectedIndex = value;
                    });
                  },
                  destinations: _navigationDestinations,
                  selectedIndex: _selectedIndex,
                  elevation: 10,
                ),
              ),
            ],
          );
        }
        // https://api.flutter.dev/flutter/material/NavigationRail-class.html
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(
                onDestinationSelected: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
                destinations: _navigationRailDestinations,
                selectedIndex: _selectedIndex,
                elevation: 10,
                extended: constraints.maxWidth >= 1440,
                minExtendedWidth: 144,
                minWidth: 72,
                labelType: NavigationRailLabelType.none,
                useIndicator: true,
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Center(
                  child: Container(
                constraints: const BoxConstraints(maxWidth: 1500),
                child: _pages[_selectedIndex],
              )),
            ),
          ],
        );
      },
    );
  }
}
