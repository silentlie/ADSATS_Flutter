import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/hazard_report/hazard_report_components.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/hazard_report/hazard_report_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HazardReportNotifier extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  Map<String, dynamic> noticeBasicDetails = {
    'file_names': <String>[],
  };
  Map<String, dynamic> hazardReportDetails = {
    'included_comment': false,
    'report_type': true,
  };
  Map<String, dynamic> recipients = {
    'roles': ['safety officer']
  };
  late ColorScheme colorScheme;
  late AuthNotifier authNotifier;
  bool isRead = true;
  bool viewMode = false;
  bool editPermission = false;

  Future<Widget> initialize(Map<String, dynamic>? noticeBasicDetails) async {
    if (noticeBasicDetails == null) {
      return buildWidget();
    }
    viewMode = true;
    this.noticeBasicDetails = noticeBasicDetails;
    isRead = noticeBasicDetails['status'];
    hazardReportDetails = await fetchHazardReportDetails(
        noticeBasicDetails['notice_id'] as String);
    recipients = {};
    return buildWidget();
  }

  Widget buildWidget() {
    return StatefulBuilder(
      builder: (context, setState) {
        colorScheme = Theme.of(context).colorScheme;
        authNotifier = Provider.of<AuthNotifier>(context, listen: false);
        return Form(
          key: formKey,
          child: Column(
            children: [
              ...hazardReportForm(context),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (viewMode && !isRead)
                      ElevatedButton.icon(
                        onPressed: () {
                          setRead(authNotifier.staffID,
                              noticeBasicDetails['notice_id'] as int);
                          context.go('/sms');
                        },
                        label: const Text('Mark as read'),
                      ),
                    const SizedBox(width: 10),
                    if (viewMode &&
                        (authNotifier.isAdmin || authNotifier.isEditor))
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            editPermission = true;
                            viewMode = false;
                          });
                        },
                        label: const Text('Edit Mode'),
                      ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.go('/sms');
                      },
                      label: const Text('Cancel'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO:Functionality for the sending button
                        debugPrint(noticeBasicDetails.toString());
                        debugPrint(hazardReportDetails.toString());
                        debugPrint(recipients.toString());
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            colorScheme.secondary),
                      ),
                      label: Text(
                        'Submit and Send',
                        style: TextStyle(color: colorScheme.onSecondary),
                      ),
                      icon: Icon(
                        Icons.mail,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  List<Widget> hazardReportForm(BuildContext context) {
    return [
      Container(
        padding: const EdgeInsets.only(bottom: 8),
        child: const Text(
          'Hazard report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Divider(),
      NoticeBasicDetails(
        noticeBasicDetails: noticeBasicDetails,
        viewMode: viewMode,
        editPermission: editPermission,
      ),
      CustomTextFormField(
        labelText: 'Location',
        jsonKey: 'location',
        results: noticeBasicDetails,
      ),
      CustomTextFormField(
        labelText: 'Describe the Hazard or the Event',
        jsonKey: 'describe',
        results: noticeBasicDetails,
        minLines: 5,
      ),
      Mitigation(hazardReportDetails: hazardReportDetails),
      const RiskSeverityWidget(),
      Container(
        padding: const EdgeInsets.all(8),
        child: SearchFileWidget(
          fileNames: noticeBasicDetails['file_names'],
          enabled: !viewMode || editPermission,
        ),
      ),
      if (!viewMode)
        const Center(
          child: Text(
            "This will send to Safety officers",
          ),
        ),
      if (viewMode)
        RecepientsWidget(
          recipients: recipients,
        ),
    ];
  }

  Future<Map<String, dynamic>> fetchHazardReportDetails(String noticeID) async {
    try {
      Map<String, String> queryParameters = {
        'notice_id': noticeID,
        ...hazardReportDetails
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.get('/sms/hazard-report',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      final data = Map<String, dynamic>.from(jsonDecode(jsonStr));
      return data;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<int> sendNoticeBasicDetails(
      Map<String, dynamic> noticeBasicDetails) async {
    try {
      Map<String, dynamic> body = {
        'archived': false,
      };
      body.addAll(noticeBasicDetails);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/sms',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send basic notice details with notice id: $id");
      return id;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> sendHazardReportDetails(
      Map<String, dynamic> hazardReportDetails, int noticeID) async {
    try {
      Map<String, dynamic> body = {
        'notice_id': noticeID,
        ...hazardReportDetails
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/sms/hazard-report',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send hazard report details with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> sendNotifications(
      Map<String, dynamic> recipients, int noticeID) async {
    try {
      Map<String, dynamic> body = {'notice_id': noticeID, ...recipients};
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/notifications',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send notification with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> setRead(int staffID, int noticeID) async {
    try {
      Map<String, dynamic> body = {
        'notice_id': noticeID,
        'staff_id': staffID,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/notifications',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish set read with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
