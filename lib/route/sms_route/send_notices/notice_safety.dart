import 'package:flutter/material.dart';
import 'recepients.dart';

class SafetyNotice extends StatelessWidget {
  const SafetyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TitleofTheNotice(),
            ],
          ),
          Row(
            children: [
              RoleRecipientsMultiSelect(),
              PlanesRecepientsMultiSelect(),
              RecepientMultiSelect()
            ],
          ),
          Divider(),
          Row(
            children: [
              AuthorTextField(),
              ReportNumberTextField(),
            ],
          ),
          SubjectTextField(),
          TitleTextField(),
          MessageTextField(),
          UploadWidget(),
          ActionButtonsWidget()
        ],
      ),
    );
  }
}

class TitleofTheNotice extends StatelessWidget {
  const TitleofTheNotice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: const Text(
        'Safety Notice',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}

class ReportNumberTextField extends StatelessWidget {
  const ReportNumberTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
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

class TitleTextField extends StatelessWidget {
  const TitleTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: const TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text('Title'),
        ),
      ),
    );
  }
}

class AuthorTextField extends StatelessWidget {
  const AuthorTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
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
          child: const Text('Save'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // Functionality for the third button
          },
          child: const Row(
            children: [
              Icon(Icons.mail), // Replace 'some_icon' with the desired icon
              SizedBox(
                  width: 5), // Adjust the spacing between the icon and text
              Text('Send Notification'),
            ],
          ),
        ),
      ],
    );
  }
}

class UploadWidget extends StatelessWidget {
  const UploadWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      width: 300,
      child: Column(
        children: [
          Text('Upload a file'),
          Icon(Icons.upload),
        ],
      ),
    );
  }
}
