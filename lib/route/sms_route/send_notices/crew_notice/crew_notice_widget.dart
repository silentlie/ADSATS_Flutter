import 'dart:convert';

import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CrewNoticeWidget extends StatelessWidget {
  const CrewNoticeWidget({
    super.key,
  });
  static Map<String, dynamic> noticeBasicDetails = {};
  static Map<String, dynamic> crewNoticeDetails = {};

  @override
  Widget build(BuildContext context) {
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final formKey = GlobalKey<FormState>();
    noticeBasicDetails['fileNames'] = <String>[];
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Crew Notice',
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
          CustomTextFormField(
            labelText: 'Message',
            jsonKey: 'message',
            results: crewNoticeDetails,
            minLines: 5,
            maxLines: 10,
          ),
          SearchFileWidget(
            fileNames: noticeBasicDetails['fileNames'],
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    // TODO:Functionality for the sending button
                    crewNoticeDetails.addAll(RecepientsWidget.recipientsResult);
                    debugPrint(noticeBasicDetails.toString());
                    debugPrint(crewNoticeDetails.toString());
                    // sendCrewNotice(crewNoticeDetails, noticeBasicDetails);
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

  Future<int> sendCrewNotice(Map<String, dynamic> crewNoticeDetails,
      Map<String, dynamic> noticeBasicDetails) async {
    try {
      int noticeID = await sendNoticeBasic(noticeBasicDetails);
      Map<String, dynamic> body = {
        'notice_id': noticeID,
      };
      body.addAll(crewNoticeDetails);
      body.addAll(RecepientsWidget.recipientsResult);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/sms/crew-notice',
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
