import 'package:flutter/material.dart';
import 'recepients.dart';

class HazardReport extends StatelessWidget {
  const HazardReport({super.key});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'Send a notice - Hazard report',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const HazardReportForm(),
        ]
      ),
    );
  }
}

class HazardReportForm extends StatelessWidget {
  const HazardReportForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Form(
      child: Column(
        children: [
          Row(
            children: [
              RoleRecipientsMultiSelect(),
              PlanesRecepientsMultiSelect(),
              RecepientMultiSelect()
            ]
          ),
          Divider(),
          Row(
            children: [
              AuthorTextField(),
              DateFormField(),
              ReportType(),
            ],
          ),
          Row(
            children: [
              SubjectTextField(),
              LocationTextField(),
            ]
          ),
          Row(
            children: [
              DescribeTextField(),
              MitigationColumn(),
            ],
          ),
          Wrap(
            children: [
              LikelihoodofOccurrenceWidget(),
              SeverityOfConsequenceWidget()
            ],
          ),
          RiskSeverityWidget(),
          CommentsTextField(),
          ActionButtonsWidget(),
        ],
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
              SizedBox(width: 5), // Adjust the spacing between the icon and text
              Text('Send Notification'),
            ],
          ),
        ),
      ],
    );
  }
}

class SeverityOfConsequenceWidget extends StatelessWidget {
  const SeverityOfConsequenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.4,
      width: 700,
      padding: const EdgeInsets.all(8),
      child:  Column(
        children: [
          const Text(
            'What do you consider to be the worst possible consequence of this event happening? Click on the table below.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all()
            ),
            child: const SeverityOfConsequenceTable()
          )
        ],
      ),
    );
  }
}

class LikelihoodofOccurrenceWidget extends StatelessWidget {
  const LikelihoodofOccurrenceWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width * 0.4,
      width: 650,
      padding: const EdgeInsets.all(8),
      child:  Column(
        children: [
          const Text(
            'In your opinion, what is the likelihood of the occurrence happening again? Click on the table below.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(''),
          Container(
            decoration: BoxDecoration(
              border: Border.all()
            ),
            child: const LikelihoodOfOccurrenceTable()
            )
        ],
      ),
    );
  }
}

class MitigationColumn extends StatelessWidget {
  const MitigationColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.4,
      child: const Column(
        children: [
          Mitigation(),
          MitigationTextField(),
        ],
      ),
    );
  }
}

class CommentsTextField extends StatelessWidget {
  const CommentsTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: const TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          label: Text('Interim action/comments')
        ),
      ),
    );
  }
}

class RiskSeverityWidget extends StatelessWidget {
  const RiskSeverityWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text(
            'Risk Severity:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Tooltip(
            message: 'Risk Severity image',
            child: Icon(
              Icons.info_outline,
              size: 20, 
            ),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              controller: TextEditingController(text: 'Unacceptable'),
              enabled: false,
              readOnly: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                fillColor: Color.fromARGB(255, 224, 106, 98),
                filled: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MitigationTextField extends StatelessWidget {
  const MitigationTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const TextField(
      decoration: InputDecoration(
        label: Text('In your opinion, how could the hazard or event be mitigated? (optional)'),
        border: OutlineInputBorder()
      ),
      maxLines: 3,
    );
  }
}

class DescribeTextField extends StatelessWidget {
  const DescribeTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.4,
      child: const TextField(
        decoration: InputDecoration(
          label: Text('Describe the Hazard or the Event'),
          border: OutlineInputBorder()
        ),
        maxLines: 5,
      ),
    );
  }
}

class LocationTextField extends StatelessWidget {
  const LocationTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.4,
      child: const TextField(
        decoration: InputDecoration(
          label: Text('Location'),
          border: OutlineInputBorder()
        ),
      ),
    );
  }
}

class SubjectTextField extends StatelessWidget {
  const SubjectTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.4,
      child: const TextField(
        decoration: InputDecoration(
          label: Text('Subject'),
          border: OutlineInputBorder()
        ),
      ),
    );
  }
}

class AuthorTextField extends StatelessWidget {
  const AuthorTextField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.3,
      child: const TextField(
        decoration: InputDecoration(
          label: Text('Form completed by'),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.search)
        ),
      ),
    );
  }
}

class DateFormField extends StatelessWidget {
  const DateFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width * 0.3,
      child: InputDatePickerFormField(
        initialDate: DateTime.timestamp(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
    );
  }
}

class ReportType extends StatefulWidget {
  const ReportType({super.key});

  @override
  State<ReportType> createState() => _ReportTypeState();
}

class _ReportTypeState extends State<ReportType> {

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 300,
      child: Row(
        children: [
          Text(
            'Type of report:',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          Radio(value: false, groupValue: ReportType(), onChanged: null),
          Text(
            'Open',
          ),
          Radio(value: false, groupValue: ReportType(), onChanged: null),
          Text(
            'Confidential',
          ),
        ],
      ),
    );
  }
}

class Mitigation extends StatefulWidget {
  const Mitigation({super.key});

  @override
  State<Mitigation> createState() => _MitigationState();
}

class _MitigationState extends State<Mitigation> {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          'Include mitigation comment?',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        Radio(value: false, groupValue: ReportType(), onChanged: null),
        Text(
          'Yes',
        ),
        Radio(value: false, groupValue: ReportType(), onChanged: null),
        Text(
          'No',
        ),
      ],
    );
  }
}


class SeverityOfConsequenceTable extends StatefulWidget {
  const SeverityOfConsequenceTable({super.key});

  @override
  State<SeverityOfConsequenceTable> createState() => _SeverityOfConsequenceTableState();
}

class _SeverityOfConsequenceTableState extends State<SeverityOfConsequenceTable> {
  late List<bool> _selected;
  late List<DataRow> _rows;
  
  @override
  void initState() {
    super.initState();
    _selected = List<bool>.generate(5, (int index) => false);
    _rows = _createRows();
  }

  void _selectRow(int index) {
    setState(() {
      for (int i = 0; i < _selected.length; i++) {
        _selected[i] = i == index;
      }
    });
  }

  List<DataRow> _createRows() {
    List<Map<String, dynamic>> data = [
      {"definition": "Catastrophic", "meaning": "Results in an accident, death or equipment destroyed", "value": "5"},
      {"definition": "Hazardous", "meaning": "Serious injury or major equipment damage", "value": "4"},
      {"definition": "Major", "meaning": "Serious incident or injury", "value": "3"},
      {"definition": "Minor", "meaning": "Results in a minor incident", "value": "2"},
      {"definition": "Negligible", "meaning": "Nuisance of little consequences", "value": "1"},
    ];

    return data.asMap().entries.map<DataRow>((entry) {
      int index = entry.key;
      Map<String, dynamic> item = entry.value;
      return DataRow(
        cells: [
          DataCell(Text(item["definition"])),
          DataCell(Text(item["meaning"])),
          DataCell(Text(item["value"])),
        ],
        selected: _selected[index],
        onSelectChanged: (bool? selected) {
          _selectRow(index);
        },
        color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (_selected[index]) return Colors.lightBlue.withOpacity(0.5);
          return Colors.transparent; // Use default color when not selected
        }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold
      ),
      showCheckboxColumn: false,
      columns: const [
        DataColumn(label: Text('Aviation definition')),
        DataColumn(label: Text('Meaning')),
        DataColumn(label: Text('Value'))
      ],
      rows: _rows,
    );
  }
}

class LikelihoodOfOccurrenceTable extends StatefulWidget {
  const LikelihoodOfOccurrenceTable({super.key});

  @override
  State<LikelihoodOfOccurrenceTable> createState() => _LikelihoodOfOccurrenceTableState();
}

class _LikelihoodOfOccurrenceTableState extends State<LikelihoodOfOccurrenceTable> {
  late List<bool> _selected;
  late List<DataRow> _rows;
  
  @override
  void initState() {
    super.initState();
    _selected = List<bool>.generate(5, (int index) => false);
    _rows = _createRows();
  }

  void _selectRow(int index) {
    setState(() {
      for (int i = 0; i < _selected.length; i++) {
        _selected[i] = i == index;
      }
    });
  }

  List<DataRow> _createRows() {
    List<Map<String, dynamic>> data = [
      {"definition": "Frequent", "meaning": "Likely to occur many time", "value": "5"},
      {"definition": "Occassional", "meaning": "Likely to occur sometimes", "value": "4"},
      {"definition": "Remote", "meaning": "Unlikely to occur but possible", "value": "3"},
      {"definition": "Improbable", "meaning": "Very unlikely to occur", "value": "2"},
      {"definition": "Extremely improbable", "meaning": "Almost inconceivable that the event will occur", "value": "1"},
    ];

    return data.asMap().entries.map<DataRow>((entry) {
      int index = entry.key;
      Map<String, dynamic> item = entry.value;
      return DataRow(
        cells: [
          DataCell(Text(item["definition"])),
          DataCell(Text(item["meaning"])),
          DataCell(Text(item["value"])),
        ],
        selected: _selected[index],
        onSelectChanged: (bool? selected) {
          _selectRow(index);
        },
        color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (_selected[index]) return Colors.lightBlue.withOpacity(0.5);
          return Colors.transparent; // Use default color when not selected
        }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold
      ),
      showCheckboxColumn: false,
      columns: const [
        DataColumn(label: Text('Qualitative definition')),
        DataColumn(label: Text('Meaning')),
        DataColumn(label: Text('Value'))
      ],
      rows: _rows,
    );
  }
}
