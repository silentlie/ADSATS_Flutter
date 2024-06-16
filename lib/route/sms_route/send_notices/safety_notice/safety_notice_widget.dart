import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SafetyNoticeWidget extends StatelessWidget {
  const SafetyNoticeWidget({super.key});
  static Map<String, dynamic> formResult = {};

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    formResult['file_names'] = <String>[];
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
          Container(
            padding: const EdgeInsets.all(5),
            child: const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Subject'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            child: const TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), label: Text('Message')),
              maxLines: 5,
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(8),
            child: SearchFileWidget(
              fileNames: formResult['file_names'],
            ),
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align buttons to the right
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
