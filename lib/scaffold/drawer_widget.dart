import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'default_widget.dart';

import 'package:adsats_flutter/Amplify/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
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
                  applicationVersion: "1.0.0");
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
    

    return const DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add some space between the top drawer and role text
          SizedBox(height: 20),
          Center(
            child: Text(
              'Drawer Image',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          // Add some space between the header text and additional text
          SizedBox(height: 20),
          Center(
            // Center the name text
            child: Text(
              'Name',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          Center(
            // Center the role text
            child: Text(
              'Role',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
