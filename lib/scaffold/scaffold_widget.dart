import 'package:flutter/material.dart';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/scaffold/appbar_widget.dart';
import 'package:adsats_flutter/scaffold/drawer_widget.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (rememberDevice) {
      rememberCurrentDevice();
    }
    return Scaffold(
      appBar: const MyAppBar(),
      endDrawer: const MyDrawer(),
      body: child,
    );
  }
}
