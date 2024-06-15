import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'default_widget.dart';

import 'package:adsats_flutter/amplify/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: const EdgeInsets.all(8),
        children: [
          const MyDrawerHeader(),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              context.go('/profile');
            },
          ),
          ListTile(
            title: const Text('Reset password'),
            onTap: () {
              context.go('/resetPassword');
            },
          ),
          if (authNotifier.isAdmin)
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                context.go('/settings');
              },
            ),
          ListTile(
            title: const Text('Help'),
            onTap: () {
              context.go('/help');
            },
          ),
          ListTile(
            title: const Text('More Info'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationIcon: const DefaultLogoWidget(),
                applicationName: "ADSATS Web App",
                applicationVersion: "1.0.0",
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              // confirm before logout?
              signOutCurrentUser();
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                  colorScheme.secondary), // Change button background color
            ),
            child: Text('Log out',
                style: TextStyle(color: colorScheme.onSecondary)),
          ),
        ],
      ),
    );
  }
}

class MyDrawerHeader extends StatelessWidget {
  const MyDrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AuthNotifier staff = Provider.of<AuthNotifier>(context, listen: false);
    Widget? avatar;
    if (staff.avatarUrl.isEmpty) {
      avatar = const DefaultLogoWidget();
    } else {
      avatar = Text(staff.avatarUrl);
    }
    return SizedBox(
      // height of header
      height: 400,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: avatar),
            // Add some space between the header text and additional text
            const SizedBox(height: 20),
            Center(
              // Center the name text
              child: Text(
                "Name: ${staff.fName} ${staff.lName}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the email text
              child: Text(
                "Email: ${staff.email}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the role text
              child: Text(
                "Roles: ${staff.roles}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the role text
              child: Text(
                "Aircraft: ${staff.aircraft}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the role text
              child: Text(
                "Categories: ${staff.categories}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the role text
              child: Text(
                "Subcategories: ${staff.subcategories}",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
