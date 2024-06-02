import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuItem {
  final String text;
  final IconData icon;
  final String route;

  // Constructor
  const MenuItem({required this.text, required this.icon, required this.route});

  String get getRoute {
    return route;
  }
}

class AppBarItems {
  static const List<MenuItem> fullMenuItems = [
    itemDocuments,
    itemSMS,
    itemCompliance,
    itemTraining,
    itemPurchases,
  ];

  static const List<MenuItem> tabletMenuItems = [
    itemDocuments,
    itemSMS,
  ];

  static const List<MenuItem> tabletPopupItems = [
    itemCompliance,
    itemTraining,
    itemPurchases,
  ];

  static const itemDocuments = MenuItem(
      text: 'Documents', icon: Icons.insert_drive_file, route: '/documents');
  static const itemSMS = MenuItem(
      text: 'S.M.S', icon: FontAwesomeIcons.helmetSafety, route: '/sms');
  static const itemCompliance = MenuItem(
      text: 'Compliance',
      icon: Icons.assignment_turned_in,
      route: '/compliance');
  static const itemTraining = MenuItem(
      text: 'Training',
      icon: FontAwesomeIcons.graduationCap,
      route: '/training');
  static const itemPurchases = MenuItem(
      text: 'Purchases',
      icon: FontAwesomeIcons.fileInvoiceDollar,
      route: '/purchases');
}
