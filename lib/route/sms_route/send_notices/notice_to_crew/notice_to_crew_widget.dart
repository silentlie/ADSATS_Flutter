import 'dart:convert';

import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

part 'notice_to_crew_class.dart';

class NoticeWidget extends StatelessWidget {
  const NoticeWidget({
    super.key,
  });
  static Map<String, dynamic> formResult = {};

  @override
  Widget build(BuildContext context) {
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    bool editMode = authNotifier.isAdmin || authNotifier.isEditor;
    formResult['fileNames'] = <String>[];
    return Form(
      key: formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              'Notice to Crew',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const Divider(),
          const RecepientsWidget(),
          const Divider(),
          Row(
            children: [
              if (editMode)
                Expanded(
                  child: SearchAuthorWidget(
                    result: formResult,
                    enabled: editMode,
                  ),
                ),
              Expanded(
                child: CustomTextFormField(
                  labelText: 'Report Number',
                  str: 'report_number',
                  results: formResult,
                  enabled: false,
                ),
              ),
            ],
          ),
          CustomTextFormField(
            labelText: 'Subject',
            str: 'subject',
            results: formResult,
          ),
          CustomTextFormField(
            labelText: 'Message',
            str: 'message',
            results: formResult,
            minLines: 5,
            maxLines: 10,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(8),
            child: SearchFileWidget(
              fileNames: formResult['fileNames'],
            ),
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
                    formResult;
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

  Future<void> sendNotice() async {
    try {
      Map<String, dynamic> body = {
        'archived': false,
      };
      body.addAll(formResult);
      // debugPrint(body.toString());
      final restOperation = Amplify.API.post('/documents',
          apiName: 'AmplifyAviationAPI', body: HttpPayload.json(body));

      final response = await restOperation.response;
      String jsonStr = response.decodeBody();
      int documentID = jsonDecode(jsonStr);
      debugPrint("document_id: $documentID");
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
