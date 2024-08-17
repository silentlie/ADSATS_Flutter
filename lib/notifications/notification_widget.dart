import 'package:adsats_flutter/amplify/auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

part 'notification_class.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  List<Widget> _buildChildrenWidgets(AuthNotifier authNotifier) {
    List<Widget> children = authNotifier.notifications.map(
      (e) {
        return e.toListTile();
      },
    ).toList();
    if (children.isEmpty) {
      children.add(
        const ListTile(
          title: Text("There is no pending notice"),
        ),
      );
    }
    children.add(
      TextButton.icon(
        onPressed: () async {
          await authNotifier.fetchCache();
          setState(() {
            _buildChildrenWidgets(authNotifier);
          });
        },
        label: const Text("Refresh"),
        icon: const Icon(Icons.refresh),
      ),
    );
    return children;
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    List<Widget> children = _buildChildrenWidgets(authNotifier);
    return MenuAnchor(
      menuChildren: children,
      alignmentOffset: const Offset(100, 0),
      builder: (context, controller, child) {
        return badges.Badge(
          position: badges.BadgePosition.topEnd(top: -5, end: -5),
          badgeContent: Text(authNotifier.notifications.length.toString()),
          showBadge: authNotifier.notifications.isNotEmpty,
          badgeAnimation: const badges.BadgeAnimation.scale(),
          child: IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
        );
      },
    );
  }
}
