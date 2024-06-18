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
                              noticeBasicDetails['notice_id']);
                          // NEED TO SET ISREAD TO TRUE
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
                          });
                        },
                        label: const Text('Edit Mode'),
                      ),
                    const SizedBox(width: 10),
                    if (!viewMode || editPermission)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go('/sms');
                        },
                        label: const Text('Cancel'),
                      ),
                    const SizedBox(width: 10),
                    if (!viewMode || editPermission)
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            debugPrint(noticeBasicDetails.toString());
                            debugPrint(hazardReportDetails.toString());
                            debugPrint(recipients.toString());
                            // context.go('/sms');
                            if (!viewMode) {
                              // int noticeID = await sendNoticeBasicDetails(noticeBasicDetails);
                              // sendHazardReportDetails(
                              //     hazardReportDetails, noticeID);
                              // sendNotifications(recipients, noticeID);
                            } else {
                              // int noticeID = noticeBasicDetails['notice_id'];
                              // updateNoticeBasicDetails(
                              //     noticeBasicDetails, noticeID);
                              // updateHazardReportDetails(
                              //     hazardReportDetails, noticeID);
                              // sendNotifications(recipients, noticeID);
                            }
                          }
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
        results: hazardReportDetails,
        enabled: !viewMode || editPermission,
      ),
      CustomTextFormField(
        labelText: 'Describe the Hazard or the Event',
        jsonKey: 'describe',
        results: hazardReportDetails,
        minLines: 5,
        enabled: !viewMode || editPermission,
      ),
      ComponentsWidget(
        hazardReportDetails: hazardReportDetails,
        enabled: !viewMode || editPermission,
      ),
      RiskSeverityWidget(
        enabled: !viewMode || editPermission,
      ),
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
        InterimCommentAndReviewDate(
          editPermission: editPermission,
          hazardReportDetails: hazardReportDetails,
        ),
      if (viewMode)
        ResolveWidget(
          noticeBasicDetails: noticeBasicDetails,
          enabled: editPermission,
        ),
      if (viewMode)
        CustomTextFormField(
          labelText: "Additional comments",
          results: hazardReportDetails,
          jsonKey: 'additional_comments',
          enabled: editPermission,
        ),
      if (viewMode && editPermission)
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
      final restOperation = Amplify.API.get('/hazard-report',
          apiName: 'AmplifyNoticesAPI', queryParameters: queryParameters);

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
      Map<String, dynamic> body = {'archived': false, ...noticeBasicDetails};
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/notices',
          apiName: 'AmplifyNoticesAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send basic notice details with notice id: $id");
      return id;
    } on ApiException catch (e) {
      debugPrint('POST call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> updateNoticeBasicDetails(
      Map<String, dynamic> noticeBasicDetails, int noticeID) async {
    try {
      Map<String, dynamic> body = {'noticeID': noticeID, ...noticeBasicDetails,};
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/notices',
          apiName: 'AmplifyNoticesAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish update basic notice details with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('PATCH call failed: $e');
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
      final restOperation = Amplify.API.post('/hazard-report',
          apiName: 'AmplifyNoticesAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send hazard report details with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('POST call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> updateHazardReportDetails(
      Map<String, dynamic> hazardReportDetails, int noticeID,) async {
    try {
      Map<String, dynamic> body = {
        'notice_id': noticeID,
        ...hazardReportDetails
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/hazard-report',
          apiName: 'AmplifyNoticesAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish update hazard report details with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('PATCH call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> sendNotifications(
      Map<String, dynamic> recipients, int noticeID) async {
    try {
      Map<String, dynamic> body = {
        'notice_id': noticeID,
        ...recipients,
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/notifications',
          apiName: 'AmplifyNotificationsAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send notification with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('POST call failed: $e');
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
          apiName: 'AmplifyNotificationsAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish set read with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('PATCH call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
