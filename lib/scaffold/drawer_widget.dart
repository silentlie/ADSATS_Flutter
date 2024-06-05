import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'default_widget.dart';

import 'package:adsats_flutter/amplify/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: const Text('Log out'),
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
    final staff = Provider.of<AuthNotifier>(context);
    return SizedBox(
      // height of header
      height: 250,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add some space between the top drawer and role text
            const SizedBox(height: 20),
            Center(
                child: staff.avatarUrl.isEmpty
                    ? const DefaultLogoWidget()
                    : Text(staff.avatarUrl)),

            // Add some space between the header text and additional text
            const SizedBox(height: 20),
            Center(
              // Center the name text
              child: Text(
                "${staff.fName} ${staff.lName}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the email text
              child: Text(
                staff.email,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the role text
              child: Text(
                staff.roles,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Center(
              // Center the role text
              child: Text(
                staff.aircrafts,
                style: const TextStyle(
                  color: Colors.black,
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
