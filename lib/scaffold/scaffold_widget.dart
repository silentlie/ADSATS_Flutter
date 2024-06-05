import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/appbar_widget.dart';
import 'package:adsats_flutter/scaffold/drawer_widget.dart';
import 'package:adsats_flutter/Amplify/auth.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthNotifier(),
      child: Scaffold(
        appBar: const MyAppBar(),
        endDrawer: const MyDrawer(),
        body: child,
      ),
    );
  }
}
