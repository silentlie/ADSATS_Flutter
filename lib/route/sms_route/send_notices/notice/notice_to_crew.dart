import 'package:adsats_flutter/route/sms_route/send_notices/search_widget.dart';
import 'package:flutter/material.dart';

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
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(maxWidth: 900),
              child: TextField(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  label: const Text('Author'),
                  suffixIcon: IconButton(
                    onPressed: () {
                      // TODO: implement search function for authors
                    },
                    icon: const Icon(Icons.search),
                  ),
                ),
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
        SearchWidget(
          fileNameResult: noticeToCrew.fileNameResult,
          endpoint: "/documents",
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Align buttons to the right
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // Functionality for the first button
              },
              label: const Text('Cancel'),
              icon: Icon(
                Icons.mail,
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Functionality for the second button
              },
              // Change text color
              label: const Text('Save'),
              icon: Icon(
                Icons.mail,
                color: colorScheme.onSecondary,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Functionality for the third button
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
