import 'package:flutter/material.dart';

import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';
import 'package:adsats_flutter/route/settings_route/aircrafts_api.dart';
import 'package:adsats_flutter/route/settings_route/staff_api.dart';
import 'package:adsats_flutter/route/settings_route/roles_api.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int _selectedIndex = 0;
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
  ];
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
                  constraints: const BoxConstraints(maxWidth: 1500),
                  child: buildPages(_selectedIndex),
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
                child: buildPages(_selectedIndex),
              )),
            ),
          ],
        );
      },
    );
  }

  Widget buildPages(int index) {
    switch (index) {
      case 0:
        return PaginatedDataTableAsync(StaffApi());
      case 1:
        return PaginatedDataTableAsync(AircraftsAPI());
      case 2:
        return PaginatedDataTableAsync(RolesAPI());
      default:
        return const Placeholder();
    }
  }
}
