import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SafetyNoticeWidget extends StatefulWidget {
  const SafetyNoticeWidget({
    super.key,
    this.viewMode = false,
    this.noticeID,
    this.noticeBasicDetails,
  });
  final int? noticeID;
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

  Future<void> getSafetyNotice() async {
    try {
      viewMode = widget.viewMode;
      editPermission = false;
      if (widget.noticeBasicDetails != null) {
        noticeBasicDetails = widget.noticeBasicDetails!;
        recipients = {};
      } else {
        noticeBasicDetails = {
          'fileNames': <String>[],
        };
        safetyNoticeDetails = {};
        recipients = {};
        return;
      }
      Map<String, String> queryParameters = {
        'notice_id': noticeBasicDetails['notice_id'].toString(),
      };
      // debugPrint(body.toString());
      final restOperation = Amplify.API.get('/sms/safety-notice',
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

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
                noticeBasicDetails:
                    noticeBasicDetails,
                viewMode: viewMode,
                editPermission: editPermission,
              ),
              const Divider(),
              CustomTextFormField(
                labelText: 'Message',
                jsonKey: 'message',
                results: safetyNoticeDetails,
                minLines: 5,
                maxLines: 10,
              ),
              const Divider(),
              SearchFileWidget(
                fileNames: noticeBasicDetails['file_names'],
              ),
              if (viewMode)
                RecepientsWidget(
                  recipients: recipients,
                ),
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  // Align buttons to the right
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (viewMode)
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: add mark as read
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
                    // No save function for now
                    // const SizedBox(width: 10),
                    // ElevatedButton.icon(
                    //   onPressed: () {
                    //     // Functionality for the second button
                    //   },
                    //   // Change text color
                    //   label: const Text('Save'),
                    //   icon: Icon(
                    //     Icons.mail,
                    //     color: colorScheme.onSecondary,
                    //   ),
                    // ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO:Functionality for the sending button
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();
                          debugPrint(noticeBasicDetails.toString());
                            debugPrint(safetyNoticeDetails.toString());
                            debugPrint(recipients.toString());
                          // sendSafetyNotice(safetyNoticeDetails, noticeBasicDetails);
                          // context.go('/sms');
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

  Future<int> sendNoticeBasic(Map<String, dynamic> noticeBasicDetails) async {
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
      int documentID = jsonDecode(jsonStr);
      debugPrint("document_id: $documentID");
      return documentID;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<int> sendSafetyNotice(Map<String, dynamic> safetyNoticeDetails,
      Map<String, dynamic> noticeBasicDetails) async {
    try {
      int noticeID = await sendNoticeBasic(noticeBasicDetails);
      Map<String, dynamic> body = {
        'notice_id': noticeID,
      };
      body.addAll(safetyNoticeDetails);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/sms/safety-notice',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int documentID = jsonDecode(jsonStr);
      debugPrint("document_id: $documentID");
      return documentID;
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
