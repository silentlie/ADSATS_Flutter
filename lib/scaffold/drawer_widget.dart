import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'default_widget.dart';
import 'package:adsats_flutter/amplify/auth.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<void> signOutCurrentUser() async {
    final result = await Amplify.Auth.signOut();
    if (result is CognitoCompleteSignOut) {
      // debugPrint('Sign out completed successfully');
    } else if (result is CognitoFailedSignOut) {
      debugPrint('Error signing user out: ${result.exception.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(
      context,
      listen: false,
    );
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
            // Change button background color
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(colorScheme.secondary),
            ),
            child: Text(
              'Log out',
              style: TextStyle(color: colorScheme.onSecondary),
            ),
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
      height: 500,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: avatar),
            // Add some space between the header text and additional text
            const SizedBox(height: 10),
            Center(
              child: Text(
                staff.name,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                staff.email,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                'Roles: ${staff.getListString("roles").join(', ')}',
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                'Aircraft: ${staff.getListString("aircraft").join(', ')}',
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              'Subcategores: ${staff.getListString("subcategories").join(', ')}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomResetPasswordForm extends StatelessWidget {
  const CustomResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Center(
              child: Text(
                'Aviation Document Storage and Tracking System',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Container(
                width: 550,
                height: 150,
                margin: const EdgeInsets.all(30),
                child: const DefaultLogoWidget(),
              ),
            ),
            Container(
              constraints: const BoxConstraints(maxWidth: 500.0, minWidth: 100),
              child: ResetPasswordForm(),
            ),
          ],
        ),
      ),
    );
  }
}
