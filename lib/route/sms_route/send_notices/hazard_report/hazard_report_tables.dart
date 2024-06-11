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
    return Container(
      width: 600,
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
      width: 600,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const Text(
            'In your opinion, what is the likelihood of the occurrence happening again? Click on the table below.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border.all()),
            child: const LikelihoodOfOccurrenceTable(),
          )
        ],
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

  Color updateColor() {
    return Colors.transparent;
    // if () {
    //   return Colors.red.shade200;
    // } else if () {
    //   return Colors.yellow.shade200;
    // } else if () {
    //   return Colors.green.shade200;
    // } else {
    //   return Colors.transparent;
    // }
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
                fillColor: textFieldColor,
                filled: true,
              ),
            ),
          )
        ],
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

late List<bool> _selectedSeverity;
late List<DataRow> _severityRows;

class _SeverityOfConsequenceTableState
    extends State<SeverityOfConsequenceTable> {
  @override
  void initState() {
    super.initState();
    _selectedSeverity = List<bool>.generate(5, (int index) => false);
    _severityRows = _createRows();
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
        DataColumn(label: Text('Definition')),
        DataColumn(label: Text('Meaning')),
        DataColumn(label: Text('Value'))
      ],
      rows: _severityRows,
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
        DataColumn(label: Text('Definition')),
        DataColumn(label: Text('Meaning')),
        DataColumn(label: Text('Value'))
      ],
      rows: _rows,
    );
  }
}

class AviationTable {
  String definition;
  String meaning;
  int value;

  AviationTable(this.definition, this.meaning, this.value);
}
