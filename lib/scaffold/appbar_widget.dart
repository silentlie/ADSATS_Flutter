import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:adsats_flutter/theme/theme_notifier.dart';
import 'package:adsats_flutter/scaffold/default_widget.dart';

// https://api.flutter.dev/flutter/material/SliverAppBar-class.html
// adjust again for fine-grained detail
const double _appBarHeight = 50;

class AppBarTextButtonList extends StatelessWidget
    implements PreferredSizeWidget {
  AppBarTextButtonList({super.key});

  final _listRoute = [
    ['Documents', '/documents'],
    ['S.M.S', '/sms'],
    ['Compliance', '/compliance'],
    ['Training', '/training'],
    ['Purchases', '/purchases'],
  ];

  @override
  Size get preferredSize => const Size.fromHeight(_appBarHeight);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (var route in _listRoute)
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: CustomTextButton(
              text: route[0],
              route: route[1],
            ),
          ),
      ],
    );
  }
}

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
            // DefaultTextLogo(),
          ],
        ), 
        title: AppBarTextButtonList(),
        centerTitle: true, 
        // bottom: AppBarTextButtonList(),
        actions: [
          // AppBarTextButtonList(),
          const ThemeSwitch(),
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

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({super.key, required this.text, required this.route});

  final String text;
  final String route;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    String currentUri = GoRouterState.of(context).uri.toString();
    return TextButton(
      onPressed: () {
        currentUri != route ? context.go(route) : null;
      },
      style: ButtonStyle(
        // todo: Need to check for cosmetic
        backgroundColor: WidgetStateProperty.all(
          currentUri == route
              ? colorScheme.primaryContainer.withOpacity(0.25)
              : Colors.transparent,
        ),
      ),
      child: Text(
        text,
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
