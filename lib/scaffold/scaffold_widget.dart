import 'package:adsats_flutter/amplify/auth.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/appbar_widget.dart';
import 'package:adsats_flutter/scaffold/drawer_widget.dart';
import 'package:provider/provider.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<AuthNotifier>(context).initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading widget can be customise
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // can make it into a error widget for more visualise
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
          if (authNotifier.numOfOverdue < 0) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: authNotifier.notificationWidgets,
                ),
              ),
            );
          }
          return Scaffold(
              appBar: const MyAppBar(),
              endDrawer: const MyDrawer(),
              body: child);
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
