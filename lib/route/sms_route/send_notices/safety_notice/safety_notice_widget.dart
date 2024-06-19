import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

part 'safety_notice_component.dart';

class SafetyNoticeWidget extends StatefulWidget {
  const SafetyNoticeWidget({
    super.key,
    this.viewMode = false,
    this.noticeBasicDetails,
  });
  final Map<String, dynamic>? noticeBasicDetails;
  final bool viewMode;

  @override
  State<SafetyNoticeWidget> createState() => _SafetyNoticeWidgetState();
}

class _SafetyNoticeWidgetState extends State<SafetyNoticeWidget> {
  final formKey = GlobalKey<FormState>();
  late Map<String, dynamic> noticeBasicDetails;
  late Map<String, dynamic> safetyNoticeDetails;
  late Map<String, dynamic> recipients;
  late bool editPermission;
  late bool viewMode = widget.viewMode;
  bool isRead = true;
  Future<void> getSafetyNotice() async {
    try {
      viewMode = widget.viewMode;
      editPermission = false;
      if (widget.noticeBasicDetails != null) {
        noticeBasicDetails = widget.noticeBasicDetails!;
        recipients = {};
        isRead = noticeBasicDetails['status'];
      } else {
        noticeBasicDetails = {
          'file_names': <String>[],
        };
        safetyNoticeDetails = {};
        recipients = {
          'roles': ['safety officer']
        };
        return;
      }
      Map<String, String> queryParameters = {
        'notice_id': noticeBasicDetails['notice_id'].toString(),
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.get('/safety-notice',
          apiName: 'AmplifyNoticesAPI', queryParameters: queryParameters);

      final response = await restOperation.response;
      final jsonStr = response.decodeBody();
      final data = Map<String, dynamic>.from(jsonDecode(jsonStr));
      safetyNoticeDetails = data;
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
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    return FutureBuilder(
      future: getSafetyNotice(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading widget can be customise
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // can make it into a error widget for more visualise
          return Text('Error: ${snapshot.error}');
        }
        return Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: const Text(
                  'Safety Notice',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const Divider(),
              NoticeBasicDetails(
                noticeBasicDetails: noticeBasicDetails,
                viewMode: viewMode,
                editPermission: editPermission,
              ),
              const Divider(),
              CustomTextFormField(
                labelText: 'Potential safety risk',
                jsonKey: 'message',
                results: safetyNoticeDetails,
                minLines: 5,
              ),
              const Divider(),
              SearchFileWidget(
                fileNames: noticeBasicDetails['file_names'],
                enabled: !viewMode || editPermission,
              ),
              if (!viewMode)
                const Center(
                  child: Text(
                    "This will send to Safety officers",
                  ),
                ),
              if (viewMode)
                ResolveWidget(
                  noticeBasicDetails: noticeBasicDetails,
                  enabled: editPermission,
                ),
              if (viewMode && editPermission)
                RecepientsWidget(
                  recipients: recipients,
                ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  // Align buttons to the right
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (viewMode && !isRead)
                      ElevatedButton.icon(
                        onPressed: () {
                          setRead(authNotifier.staffID,
                              noticeBasicDetails['notice_id']);
                          setState(() {
                            isRead = false;
                          });
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
                            debugPrint(safetyNoticeDetails.toString());
                            debugPrint(recipients.toString());
                            // context.go('/sms');
                            if (!viewMode) {
                              int noticeID =
                                  await sendNoticeBasic(noticeBasicDetails);
                              sendSafetyNotice(safetyNoticeDetails, noticeID);
                              sendNotifications(recipients, noticeID);
                            } else {
                              int noticeID = noticeBasicDetails['notice_id'];
                              updateNoticeBasic(noticeBasicDetails, noticeID);
                              updateSafetyNotice(safetyNoticeDetails, noticeID);
                              sendNotifications(recipients, noticeID);
                            }
                          }
                        },
                        style: ButtonStyle(
                          // Change button background color
                          backgroundColor: WidgetStateProperty.all<Color>(
                              colorScheme.secondary),
                        ),
                        label: Text(
                          'Send Notification',
                          style: TextStyle(color: colorScheme.onSecondary),
                        ),
                        icon: Icon(
                          Icons.mail,
                          color: colorScheme.onSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> sendNoticeBasic(
    Map<String, dynamic> noticeBasicDetails,
  ) async {
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

  Future<void> updateNoticeBasic(
    Map<String, dynamic> noticeBasicDetails,
    int noticeID,
  ) async {
    try {
      Map<String, dynamic> body = {
        'noticeID': noticeID,
        ...noticeBasicDetails,
      };
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

  Future<void> sendSafetyNotice(
    Map<String, dynamic> safetyNoticeDetails,
    int noticeID,
  ) async {
    try {
      Map<String, dynamic> body = {
        'notice_id': noticeID,
        ...safetyNoticeDetails
      };
      body.addAll(safetyNoticeDetails);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/afety-notices',
          apiName: 'AmplifyNoticesAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish send safety notice details with notice id: $id");
    } on ApiException catch (e) {
      debugPrint('POST call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<void> updateSafetyNotice(
    Map<String, dynamic> safetyNoticeDetails,
    int noticeID,
  ) async {
    try {
      Map<String, dynamic> body = {
        'notice_id': noticeID,
        ...safetyNoticeDetails
      };
      body.addAll(safetyNoticeDetails);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.patch('/safety-notices',
          apiName: 'AmplifyNoticesAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int id = jsonDecode(jsonStr);
      debugPrint("finish update safety notice details with notice id: $id");
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
