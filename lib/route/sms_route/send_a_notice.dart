// Code before original on new page from git
import 'package:flutter/material.dart';

class SendANotice extends StatefulWidget {
  const SendANotice({super.key});

  @override
  State<SendANotice> createState() => _SendANoticeState();
}

class _SendANoticeState extends State<SendANotice> {
  String _selectedType = ''; // Variable to store the selected type
  final List<String> _selectedRecipients = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Send a Notice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              height: 35,
              width: MediaQuery.of(context).size.width * 0.2,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  suffixIcon: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 1),
                    child: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        // Handle search action
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Colors.black,
          thickness: 1,
          height: 20,
        ),
        const SizedBox(height: 5),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Type:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Tooltip(
                message: 'Safety Notice',
                child: _buildRadioButton('Safety Notice'),
              ),
              const SizedBox(width: 100),
              Tooltip(
                message: 'Hazard Report',
                child: _buildRadioButton('Hazard Report'),
              ),
              const SizedBox(width: 100),
              Tooltip(
                message: 'Notice To Crew',
                child: _buildRadioButton('Notice To Crew'),
              ),
              const SizedBox(width: 100),
              Tooltip(
                message: 'BCAA Aircraft Occurrence Reports',
                child: _buildRadioButton('BCAA Aircraft Occurrence Reports'),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.black,
          thickness: 1,
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Send To:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildCheckboxColumn(
                'By Role:', ['Role 1', 'Role 2', 'Role 3', 'Role 4']),
            _buildCheckboxColumn(
                'By Plane:', ['Plane 1', 'Plane 2', 'Plane 3', 'Plane 4']),
            _buildRecipientComboBox(),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '+ Add new Recipient:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 300, // Adjusted width of the TextField
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Name',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 1),
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            // Handle search action
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Divider(
          color: Colors.black,
          thickness: 1,
          height: 20,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Form Completed By:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 300, // Adjusted width of the TextField
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Author',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 1),
                        child: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            // Handle search action
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Report Number:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                width: 300, // Adjusted width of the TextField
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Auto-generated',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Subject:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                // width normally 800
                width: 820, // Adjusted width of the TextField
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Subject name',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Message:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 800, // Adjusted width of the TextField
                child: Padding(
                  // horizontal 10
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1, // minimun number of lines
                    maxLines: null, // maximun number of lines
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      hintText: 'Text Area',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      suffixIcon: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Align buttons to the right
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
        ),
      ],
    );
  }

  Widget _buildRadioButton(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: _selectedType,
            onChanged: (String? val) {
              setState(() {
                _selectedType = val!;
                // Additional action when the radio button is clicked
                _handleRadioButtonClick(value);
              });
            },
          ),
          Text(value),
        ],
      ),
    );
  }

  void _handleRadioButtonClick(String selectedValue) {
    // Perform actions based on the selected radio button value
    switch (selectedValue) {
      case 'Safety Notice':
        // Perform action for Safety Notice
        break;
      case 'Hazard Report':
        // Perform action for Hazard Report
        break;
      case 'Notice To Crew':
        // Perform action for Notice To Crew
        break;
      case 'BCAA Aircraft Occurrence Reports':
        // Perform action for BCAA Aircraft Occurrence Reports
        break;
      default:
      // Handle default case
    }
  }

  Widget _buildCheckboxColumn(String title, List<String> checkboxes) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: checkboxes.map((checkbox) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Checkbox(
                      value: _selectedRecipients.contains(
                          checkbox), // Adjusted to check the selected recipients
                      onChanged: (value) {
                        setState(() {
                          if (value != null && value) {
                            _selectedRecipients.add(
                                checkbox); // Adjusted to add/remove the selected recipient
                          } else {
                            _selectedRecipients.remove(checkbox);
                          }
                        });
                      },
                    ),
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

  Widget _buildRecipientComboBox() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recipients:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              value: null,
              onChanged: (newValue) {
                // Handle when a recipient is selected
              },
              items: [
                DropdownMenuItem(
                  value: 'R1',
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedRecipients.contains('R1'),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              _selectedRecipients.add('R1');
                            } else {
                              _selectedRecipients.remove('R1');
                            }
                          });
                        },
                      ),
                      const Text('R1'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'R2',
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedRecipients.contains('R2'),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              _selectedRecipients.add('R2');
                            } else {
                              _selectedRecipients.remove('R2');
                            }
                          });
                        },
                      ),
                      const Text('R2'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'R3',
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedRecipients.contains('R3'),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              _selectedRecipients.add('R3');
                            } else {
                              _selectedRecipients.remove('R3');
                            }
                          });
                        },
                      ),
                      const Text('R3'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'R4',
                  child: Row(
                    children: [
                      Checkbox(
                        value: _selectedRecipients.contains('R4'),
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              _selectedRecipients.add('R4');
                            } else {
                              _selectedRecipients.remove('R4');
                            }
                          });
                        },
                      ),
                      const Text('R4'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
