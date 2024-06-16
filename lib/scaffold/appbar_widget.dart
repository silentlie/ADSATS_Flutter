import 'package:adsats_flutter/notifications/notification_widget.dart';
import 'package:adsats_flutter/scaffold/app_bar_components/app_bar_items.dart';
import 'package:adsats_flutter/scaffold/app_bar_components/menu_item_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:adsats_flutter/theme/theme_notifier.dart';
import 'package:adsats_flutter/scaffold/default_widget.dart';

// https://api.flutter.dev/flutter/material/SliverAppBar-class.html
// adjust again for fine-grained detail
const double _appBarHeight = 50;

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: AppBar(
        backgroundColor: colorScheme.secondary.withOpacity(0.3),
        leading: Container(
          padding: const EdgeInsets.all(5),
          child: const DefaultLogoWidget(),
        ),
        elevation: 20,
        titleSpacing: 0,
        leadingWidth: 81,
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MenuItemRow(menuItems: AppBarItems.fullMenuItems),
        ),
        centerTitle: true,
        actions: [
          const ThemeSwitch(),
          const NotificationWidget(),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  late bool themeBool = Provider.of<ThemeNotifier>(context).themeBool;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.7,
      child: Tooltip(
        message: 'Change theme',
        child: Switch(
          value: themeBool,
          onChanged: (value) {
            setState(() {
              themeBool = value;
              Provider.of<ThemeNotifier>(context, listen: false)
                  .switchThemeMode();
            });
          },
        ),
      ),
    );
  }
}
