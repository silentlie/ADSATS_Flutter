part of 'hazard_report_form.dart';

class RiskSeverity extends StatefulWidget {
  const RiskSeverity({super.key});

  @override
  State<RiskSeverity> createState() => _RiskSeverityState();
}

class _RiskSeverityState extends State<RiskSeverity> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class SeverityOfConsequenceWidget extends StatelessWidget {
  const SeverityOfConsequenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              'What do you consider to be the worst possible consequence of this event happening? Click on the table below.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
                decoration: BoxDecoration(border: Border.all()),
                child: const SeverityOfConsequenceTable())
          ],
        ),
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
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const Text(
              'In your opinion, what is the likelihood of the occurrence happening again? Click on the table below.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(''),
            Container(
              decoration: BoxDecoration(border: Border.all()),
              child: const LikelihoodOfOccurrenceTable(),
            )
          ],
        ),
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
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: const Column(
          children: [
            Mitigation(),
            MitigationTextField(),
          ],
        ),
      ),
    );
  }
}

class RiskSeverityWidget extends StatefulWidget {
  const RiskSeverityWidget({
    super.key,
  });

  @override
  State<RiskSeverityWidget> createState() => _RiskSeverityWidgetState();
}

List<String> riskTolerability = ['Unacceptable', 'Review', 'Acceptable'];

class _RiskSeverityWidgetState extends State<RiskSeverityWidget> {
  Color textFieldColor = Colors.transparent;
  int tableIndex = 3;
  int? _selectLikelihoodRow;
  int? _selectedLikelihood;

  Color updateColor(tableIndex) {
    if (tableIndex == 0) {
      return Colors.red.shade200;
    } else if (tableIndex == 1) {
      return Colors.yellow.shade200;
    } else if (tableIndex == 2) {
      return Colors.green.shade200;
    } else {
      return Colors.transparent;
    }
  }

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
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              size: 20,
            ),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: Image.asset('risk-severity.png'),
                      ));
            },
          ),
          SizedBox(
            width: 200,
            child: TextField(
              controller: TextEditingController(text: "1"),
              enabled: false,
              readOnly: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                fillColor: updateColor(tableIndex),
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
        label: Text(
            'In your opinion, how could the hazard or event be mitigated? (optional)'),
        border: OutlineInputBorder(),
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
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: const TextField(
          decoration: InputDecoration(
            label: Text('Describe the Hazard or the Event'),
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
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
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: const TextField(
          decoration: InputDecoration(
            label: Text('Location'),
            border: OutlineInputBorder(),
          ),
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
    return Flexible(
      flex: 2,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: const TextField(
          decoration: InputDecoration(
              label: Text('Subject'), border: OutlineInputBorder()),
        ),
      ),
    );
  }
}

class DateFormField extends StatelessWidget {
  const DateFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(5),
        child: InputDatePickerFormField(
          initialDate: DateTime.timestamp(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        ),
      ),
    );
  }
}

class SeverityOfConsequenceTable extends StatefulWidget {
  const SeverityOfConsequenceTable({super.key});

  @override
  State<SeverityOfConsequenceTable> createState() =>
      _SeverityOfConsequenceTableState();
}

class _SeverityOfConsequenceTableState
    extends State<SeverityOfConsequenceTable> {
  late List<bool> _selectedSeverity;
  late List<DataRow> _rows;

  @override
  void initState() {
    super.initState();
    _selectedSeverity = List<bool>.generate(5, (int index) => false);
    _rows = _createRows();
  }

  void _selectSeverityRow(int index) {
    setState(() {
      for (int i = 0; i < _selectedSeverity.length; i++) {
        _selectedSeverity[i] = i == index;
      }
    });
  }

  List<DataRow> _createRows() {
    List<Map<String, dynamic>> data = [
      {
        "definition": "Catastrophic",
        "meaning": "Results in an accident, death or equipment destroyed",
        "value": "5"
      },
      {
        "definition": "Hazardous",
        "meaning": "Serious injury or major equipment damage",
        "value": "4"
      },
      {
        "definition": "Major",
        "meaning": "Serious incident or injury",
        "value": "3"
      },
      {
        "definition": "Minor",
        "meaning": "Results in a minor incident",
        "value": "2"
      },
      {
        "definition": "Negligible",
        "meaning": "Nuisance of little consequences",
        "value": "1"
      },
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
        selected: _selectedSeverity[index],
        onSelectChanged: (bool? selected) {
          _selectSeverityRow(index);
          ValueNotifier(_selectSeverityRow(index));
        },
        color:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (_selectedSeverity[index]) {
            return Colors.lightBlue.withOpacity(0.5);
          }
          return Colors.transparent; // Use default color when not selected
        }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
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
  State<LikelihoodOfOccurrenceTable> createState() =>
      _LikelihoodOfOccurrenceTableState();
}

class _LikelihoodOfOccurrenceTableState
    extends State<LikelihoodOfOccurrenceTable> {
  late List<bool> _selectedLikelihood;
  late List<DataRow> _rows;

  @override
  void initState() {
    super.initState();
    _selectedLikelihood = List<bool>.generate(5, (int index) => false);
    _rows = _createRows();
  }

  void _selectLikelihoodRow(int index) {
    setState(() {
      for (int i = 0; i < _selectedLikelihood.length; i++) {
        _selectedLikelihood[i] = i == index;
      }
    });
  }

  List<DataRow> _createRows() {
    List<Map<String, dynamic>> data = [
      {
        "definition": "Frequent",
        "meaning": "Likely to occur many time",
        "value": "5"
      },
      {
        "definition": "Occassional",
        "meaning": "Likely to occur sometimes",
        "value": "4"
      },
      {
        "definition": "Remote",
        "meaning": "Unlikely to occur but possible",
        "value": "3"
      },
      {
        "definition": "Improbable",
        "meaning": "Very unlikely to occur",
        "value": "2"
      },
      {
        "definition": "Extremely improbable",
        "meaning": "Almost inconceivable that the event will occur",
        "value": "1"
      },
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
        selected: _selectedLikelihood[index],
        onSelectChanged: (bool? selected) {
          _selectLikelihoodRow(index);
          ValueNotifier(_selectLikelihoodRow(index));
        },
        color:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (_selectedLikelihood[index]) {
            return Colors.lightBlue.withOpacity(0.5);
          }
          return Colors.transparent; // Use default color when not selected
        }),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
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
