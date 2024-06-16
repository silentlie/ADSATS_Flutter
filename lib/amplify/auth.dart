import 'dart:convert';

import 'package:adsats_flutter/notifications/notification_widget.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/default_widget.dart';

Future<void> signOutCurrentUser() async {
  final result = await Amplify.Auth.signOut();
  if (result is CognitoCompleteSignOut) {
    // debugPrint('Sign out completed successfully');
  } else if (result is CognitoFailedSignOut) {
    debugPrint('Error signing user out: ${result.exception.message}');
  }
}

Future<void> forgetCurrentDevice() async {
  try {
    await Amplify.Auth.forgetDevice();
    // debugPrint('Forget device succeeded');
  } on AuthException catch (e) {
    debugPrint('Forget device failed with error: $e');
  }
}

Future<void> rememberCurrentDevice() async {
  try {
    await Amplify.Auth.rememberDevice();
    // debugPrint('Remember device succeeded');
  } on AuthException catch (e) {
    debugPrint('Remember device failed with error: $e');
  }
}

class SignInScafold extends StatelessWidget {
  const SignInScafold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('ADSATS')),
      body: Padding(
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
              // flutter logo
              Center(
                child: Container(
                  width: 550,
                  height: 150,
                  margin: const EdgeInsets.all(30),
                  child: const DefaultLogoWidget(),
                ),
              ),
              Container(
                constraints:
                    const BoxConstraints(maxWidth: 500.0, minWidth: 100),
                child: SignInForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomResetPasswordForm extends StatelessWidget {
  const CustomResetPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // flutter logo
          const Center(child: DefaultLogoWidget()),
          Container(
            constraints: const BoxConstraints(maxWidth: 500.0, minWidth: 100),
            child: ResetPasswordForm(),
          ),
        ],
      ),
    );
  }
}

class AuthNotifier with ChangeNotifier {
  int staffID = -1;
  String fName = "";
  String lName = "";
  String email = "";
  String avatarUrl = "";
  List<String> aircraft = [];
  List<String> roles = [];
  List<String> categories = [];
  List<String> subcategories = [];
  bool isAdmin = false;
  bool isEditor = false;
  List<String> staff = [];
  List<NotificationClass> notifications = [];
  List<Widget> notificationWidgets = [];
  int limit = 10;
  int numOfUnread = 0;
  int numOfOverdue = 0;

  Future<bool> initialize() async {
    fetchStaff();
    if (email.isEmpty) {
      await Future.wait([
        fetchCognitoAuthSession(),
        fetchNotifications(limit),
      ]);
    }
    return true;
  }

  Future<bool> reInitialize() async {
    fetchStaff();
    fetchCognitoAuthSession();
    fetchNotifications(limit);
    return true;
  }

  Future<void> fetchCognitoAuthSession() async {
    try {
      final cognitoPlugin =
          Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      // ignore: unused_local_variable
      final test = await cognitoPlugin.fetchAuthSession();
      final result = await cognitoPlugin.fetchUserAttributes();
      // maybe be buggy, if nothing changes this should the index of the email
      email = result[0].value;
      await fetchStaffDetails(email);
    } on AuthException catch (e) {
      debugPrint('Error retrieving auth session: ${e.message}');
    }
  }

  Future<void> fetchStaffDetails(String email) async {
    try {
      Map<String, String> queryParameters = {
        "email": email,
      };
      final restOperation = Amplify.API.get(
        '/staff',
        apiName: 'AmplifyFilterAPI',
        queryParameters: queryParameters,
      );
      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      dynamic raw = jsonDecode(jsonStr);
      if (raw.isEmpty) {
        return;
      }
      Map<String, dynamic> rawData = jsonDecode(jsonStr)[0];
      // debugPrint(rawData.toString());
      staffID = rawData["staff_id"];
      fName = rawData["f_name"];
      lName = rawData["l_name"];
      String? rolesStr = rawData["roles"] as String?;
      String? aircraftStr = rawData["aircraft"] as String?;
      String? categoriesStr = rawData["categories"] as String?;
      String? subcategoriesStr = rawData["subcategories"] as String?;
      roles = strToList(rolesStr);
      aircraft = strToList(aircraftStr);
      categories = strToList(categoriesStr);
      subcategories = strToList(subcategoriesStr);
      isAdmin = roles.contains("administrator");
      isEditor = roles.contains("editor");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  List<String> strToList(String? str) {
    return str?.split(',').map(
          (e) {
            return e.trim();
          },
        ).toList() ??
        [];
  }

  Future<void> fetchStaff() async {
    try {
      RestOperation restOperation =
          Amplify.API.get('/staff', apiName: 'AmplifyFilterAPI');
      AWSHttpResponse response = await restOperation.response;
      String jsonStr = response.decodeBody();
      // debugPrint("finished fetch staff");
      staff = List<String>.from(jsonDecode(jsonStr));
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> fetchNotifications(int limit) async {
    try {
      Map<String, String> queryParameters = {
        // 'staff_id': staffID as String,
        'staff_id': "2",
        "offset": "0",
        "limit": limit.toString(),
      };
      // debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/notifications',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      final rawData = Map<String, dynamic>.from(jsonDecode(jsonStr));
      final rows = List<Map<String, dynamic>>.from(rawData["rows"]);
      notifications = rows.map(
        (notification) {
          return NotificationClass.fromJSON(notification);
        },
      ).toList();
      numOfUnread = rawData["count"]["unread"];
      numOfOverdue = rawData["count"]["overdue"];
      rebuildNotifications();
      notifyListeners();
      debugPrint("you have $numOfOverdue overdue");
      // debugPrint("finished fetch notification");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void rebuildNotifications() {
    notificationWidgets = [
      if (numOfUnread > 0)
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            "You have $numOfUnread unread notifications",
            style: const TextStyle(color: Colors.yellow),
          ),
        ),
      if (numOfOverdue > 0)
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            "You have $numOfOverdue overdue notifications",
            style: const TextStyle(color: Colors.red),
          ),
        ),
    ];
    notificationWidgets.addAll(notifications.map(
      (notification) {
        return notification.toListTile();
      },
    ));
    notificationWidgets.add(
      Row(
        children: [
          TextButton.icon(
            onPressed: () {
              fetchNotifications(limit);
            },
            label: const Text("Refresh"),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
