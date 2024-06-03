import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/app_bar_components/app_bar_items.dart';
import 'package:go_router/go_router.dart';

class MenuItemRow extends StatelessWidget {
  const MenuItemRow({super.key, required this.menuItems});

  final List<MenuItem> menuItems;

  final double appbarBoxSize = 8.0;
  final double appbarIconSize = 20.0;
  final double appbarFontSize = 16.0;
  final double wrapSpacing = 30.0;
  final double runSpacing = 10.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String currentUri = GoRouterState.of(context).uri.toString();

    return Row(
      children: menuItems.map((item) {
        return TextButton.icon(
          onPressed: () {
            currentUri != item.route ? context.go(item.route) : null;
          },
          label: Text(
            item.text,
            style: TextStyle(
              fontSize: appbarFontSize,
              color: colorScheme.primary,
            ),
          ),
          icon: Icon(
            item.icon,
            size: appbarIconSize,
            color: colorScheme.primary,
          ),
          style: ButtonStyle(
            // todo: Need to check for cosmetic
            backgroundColor: WidgetStateProperty.all(
              currentUri == item.route
                  ? colorScheme.primaryContainer.withOpacity(0.25)
                  : Colors.transparent,
            ),
          ),
        );
      }).toList(),
    );
  }
}
