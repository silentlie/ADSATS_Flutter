import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/crew_notice/crew_notice_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/hazard_report/hazard_report_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/safety_notice/safety_notice_widget.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpecificNoticeWidget extends StatefulWidget {
  const SpecificNoticeWidget({super.key, required this.documentID});

  final int documentID;

  @override
  State<SpecificNoticeWidget> createState() => _SpecificNoticeWidgetState();
}

class _SpecificNoticeWidgetState extends State<SpecificNoticeWidget> {
  Future<Map<String, dynamic>> fetchNotice(
      BuildContext context, int noticeID, int staffID) async {
    try {
      Map<String, String> queryParameters = {
        "notice_id": noticeID.toString(),
        "staff_id": staffID.toString(),
      };
      // debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/notices',
          apiName: 'AmplifyNoticesAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);

      // debugPrint("finished fetch specific notice");
      return rawData;
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
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    return FutureBuilder(
      future: fetchNotice(context, widget.documentID, authNotifier.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading widget can be customise
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // can make it into a error widget for more visualise
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final rawData = snapshot.data!;
          switch (rawData['category']) {
            case 'Crew notice':
              return CrewNoticeWidget(
                noticeBasicDetails: rawData,
                viewMode: true,
              );
            case 'Safety notice':
              return SafetyNoticeWidget(
                noticeBasicDetails: rawData,
                viewMode: true,
              );
            case 'Hazard report':
              return HazardReportWidget(
                noticeBasicDetails: rawData,
              );
            case 'BCAA report':
              return const Placeholder();
            default:
              return const Placeholder();
          }
        } else {
          return const Placeholder();
        }
      },
    );
  }
}
