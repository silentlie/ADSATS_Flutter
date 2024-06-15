import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wrapfit/wrapfit.dart';

part 'notice_to_crew_class.dart';

class NoticeWidget extends StatelessWidget {
  const NoticeWidget({super.key, required this.recepients});

  final Widget recepients;

  static Map<String, List<String>> formResult = {};

  @override
  Widget build(BuildContext context) {
    NoticeToCrew noticeToCrew = NoticeToCrew();
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    Map<String, dynamic> results = {};
    bool editMode = true;
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
          recepients,
          const Divider(),
          Wrap2(
            children: [
              if (authNotifier.isAdmin || authNotifier.isEditor)
                Wrapped(
                  fit: WrapFit.runLoose,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: SearchAuthorWidget(
                      result: results,
                      enabled: editMode,
                    ),
                  ),
                ),
              Wrapped(
                fit: WrapFit.runLoose,
                child: CustomTextFormField(
                  labelText: 'Report Number',
                  str: 'report_number',
                  results: results,
                  enabled: false,
                ),
              ),
            ],
          ),
          CustomTextFormField(
            labelText: 'Subject',
            str: 'subject',
            results: results,
          ),
          CustomTextFormField(
            labelText: 'Message',
            str: 'message',
            results: results,
            minLines: 5,
            maxLines: 10,
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(8),
            child: SearchFileWidget(
              fileNameResult: noticeToCrew.fileNameResult,
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
                    noticeToCrew;
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
}
