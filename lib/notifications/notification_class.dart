part of 'notification_widget.dart';

class NotificationClass {
  late int noticeID;
  late String subject;
  late String email;
  late bool read;
  DateTime? readAt;

  NotificationClass.fromJSON(Map<String, dynamic> json) {
    noticeID = json["notice_id"] as int;
    subject = json["subject"] as String;
    email = json["email"] as String;
    read = intToBool(json["status"] as int)!;
    readAt =
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]);
  }

  static bool? intToBool(int? value) {
    if (value == null) {
      return null;
    }
    return value != 0;
  }

  ListTile toListTile() {
    return ListTile(
      visualDensity: VisualDensity.comfortable,
      tileColor: read ? Colors.blue.shade100 : Colors.transparent,
      titleTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      title: read
          ? RichText(
              text: TextSpan(
                text: 'Author: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(text: email),
                ],
              ),
            )
          : Text(
              "Author: $email",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
      subtitle: read
          ? RichText(
              text: TextSpan(
                text: 'Subject: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(text: subject),
                ],
              ),
            )
          : Text(
              "Subject: $subject",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
      trailing: Builder(builder: (context) {
        return IconButton(
            onPressed: () {
              context.go('/$noticeID');
            },
            icon: const Icon(
              Icons.more_vert,
              size: 20,
            ));
      }),
      leading: const Icon(Icons.edit_document),
      onTap: () {},
    );
  }
}
