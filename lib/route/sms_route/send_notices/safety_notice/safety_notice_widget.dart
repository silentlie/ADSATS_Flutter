import 'dart:convert';

import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SafetyNoticeWidget extends StatelessWidget {
  const SafetyNoticeWidget({super.key});
  static Map<String, dynamic> noticeBasicDetails = {};
  static Map<String, dynamic> safetyNoticeDetails = {};

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    noticeBasicDetails['file_names'] = <String>[];
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
          const NoticeBasicDetails(),
          const Divider(),
          CustomTextFormField(
            labelText: 'Subject',
            jsonKey: 'subject',
            results: noticeBasicDetails,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: const TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), label: Text('Message')),
              maxLines: 5,
            ),
          ),
          SearchFileWidget(
            fileNames: noticeBasicDetails['file_names'],
          ),
          Row(
            // Align buttons to the right
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
                    safetyNoticeDetails
                        .addAll(RecepientsWidget.recipientsResult);
                    noticeBasicDetails;
                    safetyNoticeDetails;
                    // sendSafetyNotice(safetyNoticeDetails, noticeBasicDetails);
                    context.go('/sms');
                  }
                },
                style: ButtonStyle(
                  // Change button background color
                  backgroundColor:
                      WidgetStateProperty.all<Color>(colorScheme.secondary),
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
        ],
      ),
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
