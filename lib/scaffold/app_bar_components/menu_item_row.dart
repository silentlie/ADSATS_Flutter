import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/app_bar_components/app_bar_items.dart';

const double appbarBoxSize = 8.0;
const double appbarIconSize = 20.0;
const double appbarFontSize = 16.0;
const double wrapSpacing = 30.0;
const double runSpacing = 10.0;

class MenuItemRow extends StatelessWidget {
  final List<MenuItem> menuItems;

  const MenuItemRow({super.key, required this.menuItems});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: wrapSpacing,
      runSpacing: runSpacing,
      children: menuItems.map((item) {
        return Row(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: appbarIconSize,
              color: colorScheme.primary,
            ),
            const SizedBox(width: appbarBoxSize),
            Text(
              item.text,
              style: TextStyle(
                fontSize: appbarFontSize,
                color: colorScheme.primary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
