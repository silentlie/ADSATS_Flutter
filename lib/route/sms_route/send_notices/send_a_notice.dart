import 'package:flutter/material.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class SendANotices extends StatefulWidget {
  const SendANotices({super.key});

   @override
  _SendANoticesState createState() => _SendANoticesState();
}

class _SendANoticesState extends State<SendANotices> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notice to Crew'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send To:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildCheckboxColumn('By Role:', ['Role 1', 'Role 2', 'Role 3', 'Role 4']),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'By Plane:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: ['Plane 1', 'Plane 2', 'Plane 3', 'Plane 4'].map((checkbox) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10), // Reduce horizontal padding
                              child: Row(
                                children: [
                                  Checkbox(value: false, onChanged: (value) {}),
                                  Text(checkbox),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 300, // Adjusted width of the MultiSelectDropDown
                          child: MultiSelectDropDown(
                            onOptionSelected: (options) {
                              debugPrint(options.toString());
                            },
                            options: const <ValueItem>[
                              ValueItem(label: 'Recipient 1', value: '1'),
                              ValueItem(label: 'Recipient 2', value: '2'),
                              ValueItem(label: 'Recipient 3', value: '3'),
                              ValueItem(label: 'Recipient 4', value: '4'),
                              ValueItem(label: 'Recipient 5', value: '5'),
                              ValueItem(label: 'Recipient 6', value: '6'),
                            ],
                            maxItems: null,
                            disabledOptions: const [ValueItem(label: 'Recipient 1', value: '1')],
                            selectionType: SelectionType.multi,
                            chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                            dropdownHeight: 300,
                            optionTextStyle: const TextStyle(fontSize: 16),
                            selectedOptionIcon: const Icon(Icons.check_circle),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '+ Add new Recipient:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                        width: 300, // Adjusted width of the TextField
                        child: TextField(
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                            hintText: 'Name',
                            hintStyle: const TextStyle(fontSize: 15), // Adjust font size here
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                // Handle search action
                              },
                            ),
                          ),
                        ),
                      ),

                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(
                color: Colors.black,
                thickness: 1,
                height: 20,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    child: Text(
                      'Form Completed By:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                  width: 320, // Adjusted width of the TextField
                  child: TextField(
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 15), // Adjust font size here
                    decoration: InputDecoration(
                      hintText: 'Author',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Handle search action
                        },
                      ),
                    ),
                  ),
                ),
                  const SizedBox(width: 20),
                  const Text(
                    'Report Number:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                  width: 320, // Adjusted width of the TextField
                  child: TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Auto-generated',
                      hintStyle: const TextStyle(fontSize: 15), // Adjust font size here
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          // Handle search action
                        },
                      ),
                    ),
                  ),
                ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 20),
                SizedBox( // Replace Expanded with SizedBox
                  width: 860, // Set width to 400
                  child: TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Subject Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      // Update the TextStyle for the hint text
                      hintStyle: TextStyle(fontSize: 15), // <-- Change font size to 15
                    ),
                  ),
                ),
              ],
            ),
              const SizedBox(height: 20),
              const Text(
                'Message:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
              width: 930, // Adjusted width of the TextField
              child: TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1, // minimum number of lines
                maxLines: null, // maximum number of lines
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15), // Adjust font size here
                decoration: InputDecoration(
                  hintText: 'Text Area',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
              ),
            ),
              const SizedBox(height: 20),
              Row(
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
                        SizedBox(width: 5), // Adjust the spacing between the icon and text
                        Text('Send Notification'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxColumn(String title, List<String> checkboxes) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15, // Updated font size to 20
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: checkboxes.map((checkbox) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10), // Reduce horizontal padding
              child: Row(
                children: [
                  Checkbox(value: false, onChanged: (value) {}),
                  Text(checkbox),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
}