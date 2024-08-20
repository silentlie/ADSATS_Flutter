import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/default_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignInWidget extends StatelessWidget {
  const SignInWidget({super.key});

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

class AuthNotifier with ChangeNotifier {
  int id = -1;
  String name = "";
  String email = "";
  String avatarUrl = "";
  List<int> roleIds = [];
  List<int> aircraftIds = [];
  Map<int, int> subcategoryIds = {};
  bool isAdmin = false;
  bool isEditor = false;
  Map<String, Map<int, String>> _cache = {
    "staff": {},
    "aircraft": {},
    "roles": {},
    "categories": {},
    "subcategories": {},
  };
  Map<int, String> get staffCache => _cache["staff"] ?? {};
  Map<int, String> get aircraftCache => _cache["aircraft"] ?? {};
  Map<int, String> get rolesCache => _cache["roles"] ?? {};
  Map<int, String> get categoriesCache => _cache["categories"] ?? {};
  Map<int, String> get subcategoriesCache => _cache["subcategories"] ?? {};
  List<Notification> notifications = [];
  List<Widget> notificationWidgets = [];
  int overdueCount = 0;

  Future<bool> initialize() async {
    id < 0 ? await fetchCache() : fetchCache();
    return true;
  }

  Future<bool> reInitialize() async {
    await fetchCache();
    return true;
  }

  Future<String> fetchCognitoAuthSession() async {
    try {
      final cognitoPlugin =
          Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      // ignore: unused_local_variable
      final test = await cognitoPlugin.fetchAuthSession();
      final result = await cognitoPlugin.fetchUserAttributes();
      // maybe be buggy, if nothing changes this should the index of the email
      return result[0].value;
    } on AuthException catch (e) {
      debugPrint('Error retrieving auth session: ${e.message}');
      rethrow;
    }
  }

  Future<void> fetchCache() async {
    try {
      Map<String, String>? queryParameters = {
        "cache": await fetchCognitoAuthSession(),
      };
      RestOperation restOperation = Amplify.API.get(
        '/cache',
        apiName: 'adsatsStaffAPI',
        queryParameters: queryParameters,
      );
      AWSHttpResponse response = await restOperation.response;
      String jsonStr = response.decodeBody();
      final json = Map<String, dynamic>.from(
        jsonDecode(
          jsonStr,
        ),
      );
      _parseCache(json);
      _parseStaffDetails(json);
      _parseNotifcations(json);
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void _parseNotifcations(Map<String, dynamic> json) {
    final jsonList = List<Map<String, dynamic>>.from(json["notifications"]);
    notifications = jsonList.map((json) {
      return Notification.fromJSON(json);
    }).toList();
    overdueCount = notifications.where(
      (element) {
        return element.isOverdue;
      },
    ).length;
  }

  void _parseStaffDetails(Map<String, dynamic> json) {
    Map<String, dynamic> staff = json["specific_staff"][0];
    id = staff["staff_id"];
    name = staff["staff_name"] ?? "";
    email = staff["email"] ?? "";
    List<int> toListInt(List input) {
      return input.map(
        (item) {
          return Map<String, int>.from(item).values.first;
        },
      ).toList();
    }

    aircraftIds = toListInt(json["aircraft_ids"]);
    roleIds = toListInt(json["role_ids"]);
    if (roleIds.contains(1)) {
      isAdmin = true;
    }
    if (roleIds.contains(2)) {
      isEditor = true;
    }
    subcategoryIds = {
      for (var item in json["subcategory_ids"] ?? [])
        item["subcategory_id"] as int: item["access_level_id"] as int
    };
  }

  void _parseCache(Map<String, dynamic> json) {
    Map<int, String> parseJsonToMap(
      dynamic jsonList,
      String idKey,
      String nameKey,
    ) {
      return {
        for (var item in jsonList ?? [])
          item[idKey] as int: item[nameKey] as String
      };
    }

    _cache = {
      "staff": parseJsonToMap(
        json["staff"],
        "staff_id",
        "staff_name",
      ),
      "aircraft": parseJsonToMap(
        json["aircraft"],
        "aircraft_id",
        "aircraft_name",
      ),
      "roles": parseJsonToMap(
        json["roles"],
        "role_id",
        "role_name",
      ),
      "categories": parseJsonToMap(
        json["categories"],
        "category_id",
        "category_name",
      ),
      "subcategories": parseJsonToMap(
        json["subcategories"],
        "subcategory_id",
        "subcategory_name",
      ),
    };
  }

  List<String> getListString(String input) {
    if (id < 0) {
      throw ArgumentError('getListString: Initialize failed.');
    }

    // Map of input to cache and ID list
    final cacheMap = {
      "roles": {"ids": roleIds, "cache": rolesCache},
      "aircraft": {"ids": aircraftIds, "cache": aircraftCache},
      "subcategories": {
        "ids": subcategoryIds.keys.toList(),
        "cache": subcategoriesCache
      },
    };

    // Retrieve the appropriate cache and IDs based on input
    final selected = cacheMap[input];
    if (selected == null) {
      throw ArgumentError('getListString: Invalid Input.');
    }

    final ids = selected["ids"] as List<int>;
    final cache = selected["cache"] as Map<int, String>;

    // Return list of strings from cache
    return [for (var key in ids) cache[key] ?? "Error: Missing key $key"];
  }
}

class Notification {
  late int noticeId;
  late String subject;
  late String type;
  late int staffId;
  DateTime? noticedAt;
  DateTime? deadlineAt;
  late bool isOverdue;
  Notification.fromJSON(Map<String, dynamic> json) {
    noticeId = json["notice_id"];
    subject = json["subject"];
    type = json["type"];
    staffId = json["staff_id"];
    noticedAt = DateTime.tryParse(json["noticed_at"] ?? '');
    deadlineAt = DateTime.tryParse(json["deadline_at"] ?? '');
    isOverdue = deadlineAt?.isBefore(DateTime.now()) ?? false;
  }

  IconData _getIcon(String type) {
    switch (type) {
      case "Notice to crew":
        return Icons.notifications_outlined;
      case "Safety notice":
        return Icons.gpp_maybe_outlined;
      case "Hazard report":
        return Icons.report_outlined;
      default:
        return Icons.question_mark;
    }
  }

  Widget toListTile() {
    return Builder(builder: (context) {
      AuthNotifier authNotifier =
          Provider.of<AuthNotifier>(context, listen: false);
      return ListTile(
        visualDensity: VisualDensity.standard,
        tileColor: Colors.blue.shade100,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        title: RichText(
          text: TextSpan(
            text: 'Author: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: <TextSpan>[
              TextSpan(
                text: authNotifier.staffCache[staffId],
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        subtitle: RichText(
          text: TextSpan(
            text: 'Subject: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
            children: <TextSpan>[
              TextSpan(
                text: subject,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        leading: Icon(_getIcon(type)),
        onTap: () {
          context.go('/sms/$noticeId');
        },
        // trailing: MenuAnchor(
        //   menuChildren: const [
        //     read
        //         ? ListTile(
        //             title: const Text("Mark as unread"),
        //             onTap: () {
        //               // handling mark as unread
        //             },
        //           )
        //         : ListTile(
        //             title: const Text("Mark as read"),
        //             onTap: () {
        //               // handling mark as read
        //             },
        //           ),
        //   ],
        //   builder: (context, controller, child) {
        //     return IconButton(
        //       onPressed: () {
        //         if (controller.isOpen) {
        //           controller.close();
        //         } else {
        //           controller.open();
        //         }
        //       },
        //       icon: const Icon(
        //         Icons.more_vert,
        //         size: 20,
        //       ),
        //     );
        //   },
        // ),
      );
    });
  }
}
