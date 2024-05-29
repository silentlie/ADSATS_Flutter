import 'package:flutter/material.dart';

// First DataTable data
final List<Map<String, dynamic>> dataNotification = [
  {
    'Alert': '',
    'Aircraft': 'Aircraft 1',
    'Type of Notification': 'Notification 1',
    'Report Number': '12345',
    'Subject': 'Subject 1',
    'Date': '2024-05-16',
  },
  {
    'Alert': '',
    'Aircraft': 'Aircraft 2',
    'Type of Notification': 'Notification 2',
    'Report Number': '54321',
    'Subject': 'Subject 2',
    'Date': '2024-05-15',
  },
];

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.center,
          child: Text(
            'Welcome back!',
            style: TextStyle(
              // Adjust font size if needed
              fontSize: 16,
              // Make the text bold
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add some space between "Welcome back" and the child text below "Notices"
        const SizedBox(height: 20),
        Align(
          alignment:
              // Align the text at the center horizontally
              Alignment.center,
          child: Text(
            // notifications text for the first table
            'You have ${dataNotification.length} unread Notices',
            style: const TextStyle(
              // Set font size to 25
              fontSize: 25,
              // Make the text bold
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Add some space between both DataTables
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.center,
          child: DataTable(
            columnSpacing: 10,
            columns: const [
              DataColumn(label: Text('Alert'), tooltip: 'Alert'),
              DataColumn(label: Text('Aircraft'), tooltip: 'Aircraft'),
              DataColumn(
                  label: Text('Type of Notification'),
                  tooltip: 'Type of notification'),
              DataColumn(
                  label: Text('Report Number'), tooltip: 'Report number'),
              DataColumn(label: Text('Subject'), tooltip: 'Subject'),
              DataColumn(label: Text('Date'), tooltip: 'Date'),
              DataColumn(label: Text('Actions'), tooltip: 'Actions'),
            ],
            rows: List.generate(dataNotification.length, (index) {
              final row = dataNotification[index];
              return DataRow(
                cells: [
                  DataCell(Text(row['Alert'].toString())),
                  DataCell(Text(row['Aircraft'].toString())),
                  DataCell(Text(row['Type of Notification'].toString())),
                  DataCell(Text(row['Report Number'].toString())),
                  DataCell(Text(row['Subject'].toString())),
                  DataCell(Text(row['Date'].toString())),
                  DataCell(
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Implement view action here
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Message'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        // Replace with your view details
                                        Text('Message details go here...'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            'View',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Add space between buttons
                        GestureDetector(
                          onTap: () {
                            // Implement archive action here
                          },
                          child: const Text(
                            'Archive',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
