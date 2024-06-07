import 'package:flutter/material.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/recipients.dart';

class SendANotices extends StatelessWidget {
  const SendANotices({super.key, required this.recepients});

  final Widget recepients;

  static Map<String, List<String>> formResult = {};

  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> recipientsResult =
        RecepientsWidget.recipientsResult;
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
        const Wrap(
          children: [
            AuthorTextField(),
            ReportNumberTextField(),
          ],
        ),
        const SubjectTextField(),
        const MessageTextField(),
        // const UploadWidget(),
        const ActionButtonsWidget()
      ],
    );
  }
}

class AuthorTextField extends StatelessWidget {
  const AuthorTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: TextField(
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            label: const Text('Author'),
            suffixIcon:
                IconButton(onPressed: () {}, icon: const Icon(Icons.search))),
      ),
    );
  }
}

class ReportNumberTextField extends StatelessWidget {
  const ReportNumberTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: const TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            label: Text('Report Number'),
            enabled: false),
      ),
    );
  }
}

class MessageTextField extends StatelessWidget {
  const MessageTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: const TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(), label: Text('Message')),
        maxLines: 3,
      ),
    );
  }
}

class SubjectTextField extends StatelessWidget {
  const SubjectTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: const TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text('Subject'),
        ),
      ),
    );
  }
}

class ActionButtonsWidget extends StatelessWidget {
  const ActionButtonsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme =
        Theme.of(context).colorScheme; // Access color scheme
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
      children: [
        ElevatedButton(
          onPressed: () {
            // Functionality for the first button
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Functionality for the second button
          },
          child: const Text('Save'), // Change text color
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Functionality for the third button
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
                colorScheme.secondary), // Change button background color
          ),
          child: Row(
            children: [
              Icon(Icons.mail, color: colorScheme.onSecondary),
              const SizedBox(
                  width: 5), // Adjust the spacing between the icon and text
              Text('Send Notification',
                  style: TextStyle(color: colorScheme.onSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
