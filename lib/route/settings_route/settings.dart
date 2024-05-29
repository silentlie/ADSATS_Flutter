import 'package:flutter/material.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.none;
  final List<NavigationRailDestination> _destinations = [
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
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 800;
    if (isMobile) {
      return const Placeholder();
    }
    return Row(
      children: [
        NavigationRail(
          onDestinationSelected: (value) {
            _selectedIndex = value;
          },
          destinations: _destinations,
          selectedIndex: _selectedIndex,
          elevation: 5,
          minWidth: 50,
          extended: false,
          labelType: labelType,
          useIndicator: true,
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: buildPages(_selectedIndex)),
      ],
    );
  }

  Widget buildPages(int index) {
    switch (index) {
      case 0:
        return const Placeholder();
      case 1:
        return const Placeholder();
      case 2:
        return const Placeholder();
      default:
        return const Placeholder();
    }
  }
}
