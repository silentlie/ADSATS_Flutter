import 'dart:convert';

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'package:adsats_flutter/scaffold/default_widget.dart';

Future<void> signOutCurrentUser() async {
  final result = await Amplify.Auth.signOut();
  if (result is CognitoCompleteSignOut) {
    safePrint('Sign out completed successfully');
  } else if (result is CognitoFailedSignOut) {
    safePrint('Error signing user out: ${result.exception.message}');
  }
}

Future<void> forgetCurrentDevice() async {
  try {
    await Amplify.Auth.forgetDevice();
    safePrint('Forget device succeeded');
  } on AuthException catch (e) {
    safePrint('Forget device failed with error: $e');
  }
}

Future<void> rememberCurrentDevice() async {
  try {
    await Amplify.Auth.rememberDevice();
    safePrint('Remember device succeeded');
  } on AuthException catch (e) {
    safePrint('Remember device failed with error: $e');
  }
}

class SignInScafold extends StatelessWidget {
  const SignInScafold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ADSATS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // flutter logo
              const Center(child: DefaultLogoWidget()),
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
  List<String> staff = [];
  Future<bool> initialize() async {
    if (email.isEmpty) {
      await fetchCognitoAuthSession();
      await fetchStaffDetails(email);
    }
    fetchStaff();
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

      debugPrint(email);
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
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
      Map<String, dynamic> rawData = jsonDecode(jsonStr)[0];
      debugPrint(rawData.toString());
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
      safePrint("did fetch staff");
      staff = List<String>.from(jsonDecode(jsonStr));
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
