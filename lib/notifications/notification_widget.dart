import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        ListTile(
          visualDensity: VisualDensity.comfortable,
          tileColor: Colors.blue.shade100,
          titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          title: const Text('Author'),
          subtitle: const Row(
            children: [
              Text(
                'Subject: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Message')
            ],
          ),
          trailing: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.more_vert,
                size: 20,
              )),
          leading: const Icon(Icons.edit_document),
          onTap: () {},
        ),
        ListTile(
          dense: true,
          title: const Text('Author'),
          subtitle: const Text('Subject: Message'),
          trailing: const Icon(Icons.more_vert),
          leading: const Icon(Icons.edit_document),
          onTap: () {},
        ),
        ListTile(
          dense: true,
          title: const Text('Author'),
          subtitle: const Text('Subject: Message'),
          trailing: const Icon(Icons.more_vert),
          leading: const Icon(Icons.edit_document),
          onTap: () {},
        ),
        const SizedBox(
          width: 300,
        )
      ],
      builder: (context, controller, child) {
        return IconButton(
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            icon: const Icon(Icons.notifications_none));
      },
    );
  }
}
