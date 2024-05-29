import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/app_bar_components/app_bar_items.dart';
import 'package:adsats_flutter/scaffold/default_widget.dart';

import 'menu_item_row.dart';

class AppBarTitle extends StatelessWidget {
  const AppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final double maxWidth = screenWidth < 800 ? 100 : 600;

    return Row(
      children: [
        const DefaultTextLogo(),
        const SizedBox(width: 30),
        //ConstrainedBox(
        //constraints: BoxConstraints.loose(Size(maxWidth, double.infinity)),
        //child:
        MenuItemRow(
            menuItems: (screenWidth < 820)
                ? AppBarItems.tabletMenuItems
                : AppBarItems.fullMenuItems),
      ],
    );
  }

  List<PopupMenuEntry<MenuItem>> _buildPopupMenuItems(
      List<MenuItem> popupItems) {
    return popupItems.map((item) {
      return PopupMenuItem<MenuItem>(
        child: Row(
          children: [
            Icon(item.icon, size: 20.0),
            const SizedBox(width: 12),
            Text(item.text),
          ],
        ),
      );
    }).toList();
  }
}