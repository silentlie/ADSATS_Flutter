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
        leading: const Row(
          children: [
            DefaultLogoWidget(),
            DefaultTextLogo(),
          ],
        ),
        leadingWidth: 105,
        title: const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MenuItemRow(menuItems: AppBarItems.fullMenuItems),
        ),
        centerTitle: true,
        actions: [
          const ThemeSwitch(),
          const SampleMenuWidget(),
          IconButton(
            // Add the bell icon here
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle bell icon press
            },
          ),
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

class SampleMenuWidget extends StatelessWidget {
  const SampleMenuWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(

        // offset: Offset.fromDirection(100),
        position: PopupMenuPosition.under,
        icon: const Icon(Icons.notifications),
        itemBuilder: (context) => [
              const PopupMenuItem(
                  child: SizedBox(
                width: 300,
                // height: 100,
                child: Row(
                  children: [
                    Column(
                      children: [Icon(Icons.abc)],
                    ),
                    Column(
                      children: [
                        Row(
                          children: [Text('Author'), Text('Date')],
                        ),
                        Row(
                          children: [Text('Message')],
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // IconButton(
                        //     onPressed: () {}, icon: const Icon(Icons.abc))
                      ],
                    )
                  ],
                ),
              )),
              const PopupMenuItem(child: Text('data')),
              const PopupMenuItem(child: Text('data')),
            ]);
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
      scale: 0.6,
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
    );
  }
}
