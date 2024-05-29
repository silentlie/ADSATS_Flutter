import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

// https://pub.dev/documentation/amplify_auth_cognito/latest/amplify_auth_cognito/AmplifyAuthCognito/fetchUserAttributes.html
Future<String> fetchCognitoAuthSession() async {
  try {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    // ignore: unused_local_variable
    final test = await cognitoPlugin.fetchAuthSession();
    final result = await cognitoPlugin.fetchUserAttributes();
    // maybe be buggy, if nothing changes this should the index of the email
    final identityId = result[0].value;
    return identityId;
  } on AuthException catch (e) {
    safePrint('Error retrieving auth session: ${e.message}');
  }
  return "";
}

Future<String> postTodo(String id) async {
  try {
    final restOperation = Amplify.API.post(
      apiName: 'AmplifyAPI',
      '/test',
      body: HttpPayload.json({'email': id}),
    );
    final response = await restOperation.response;
    safePrint('POST call succeeded');
    safePrint(response.decodeBody());
    return response.decodeBody();
  } on ApiException catch (e) {
    safePrint('POST call failed: $e');
  }
  return "";
}

Future<String> getMethod(Map<String, String> queryParameters) async {
  try {
    final restOperation = Amplify.API
        .get('/test', apiName: 'AmplifyAPI', queryParameters: queryParameters);
    final response = await restOperation.response;
    final responseString = response.decodeBody();
    safePrint(responseString);
    return responseString;
  } on ApiException catch (e) {
    safePrint('POST call failed: $e');
    return e.message;
  }
}
