import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

part 'notification_class.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  Future<List<Widget>> fetchNotifications(
      BuildContext context, int startIndex) async {
    // ignore: unused_local_variable
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    try {
      Map<String, String> queryParameters = {
        // 'staff_id': authNotifier.staffID as String,
        'staff_id': "2",
        "offset": startIndex.toString(),
        "limit": "10"
      };
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/notifications',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      List<Map<String, dynamic>> rawData =
          List<Map<String, dynamic>>.from(jsonDecode(jsonStr));
      debugPrint(rawData.length.toString());
      debugPrint("finished fetch specific notice");
      return rawData.map(
        (notification) {
          return NotificationClass.fromJSON(notification).toListTile();
        },
      ).toList();
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    return MenuAnchor(
      menuChildren: authNotifier.notificationWidgets,
      builder: (context, controller, child) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.notifications_none),
        );
      },
    );
  }
}
