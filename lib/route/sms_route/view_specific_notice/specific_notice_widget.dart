import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class SpecificNoticeWidget extends StatefulWidget {
  const SpecificNoticeWidget({super.key, required this.documentID});

  final int documentID;

  @override
  State<SpecificNoticeWidget> createState() => _SpecificNoticeWidgetState();
}

class _SpecificNoticeWidgetState extends State<SpecificNoticeWidget> {
  Future<void> fetchNotice(BuildContext context) async {
    try {
      Map<String, String> queryParameters = {};
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/sms',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);

      debugPrint("finished fetch specific notice");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchNotice(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading widget can be customise
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // can make it into a error widget for more visualise
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return const Column(
            children: [],
          );
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
