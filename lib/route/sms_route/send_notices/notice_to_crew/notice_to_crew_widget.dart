import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Column(
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
        Wrap(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SearchAuthorWidget(
                customClass: noticeToCrew,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(maxWidth: 400),
              child: const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text('Report Number'),
                  enabled: false,
                ),
              ),
            ),
          ],
        ),
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
            fileNameResult: noticeToCrew.fileNameResult,
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
              icon: Icon(
                Icons.mail,
                color: colorScheme.onSecondary,
              ),
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
    );
  }
}