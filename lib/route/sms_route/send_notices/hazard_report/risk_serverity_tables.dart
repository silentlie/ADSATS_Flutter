part of 'hazard_report_widget.dart';

class RiskSeverityWidget extends StatefulWidget {
  const RiskSeverityWidget({super.key});

  @override
  State<RiskSeverityWidget> createState() => _RiskSeverityWidgetState();
}

class _RiskSeverityWidgetState extends State<RiskSeverityWidget> {
  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SeverityOfConsequenceWidget(),
        LikelihoodofOccurrenceWidget(),
        RiskSeverityResult(),
      ],
    );
  }
}

class RiskSeverityResult extends StatelessWidget {
  const RiskSeverityResult({super.key});

  @override
  Widget build(BuildContext context) {
    RiskSeverity riskSeverity = Provider.of<RiskSeverity>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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
                      content: Image.asset('Risk-severity-chart.png'),
                    ));
          },
        ),
        Flexible(
          flex: 5,
          child: CustomTextFormField(
            controller: TextEditingController(text: riskSeverity.getText()),
            enabled: false,
            readOnly: true,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              fillColor: riskSeverity.getColor(),
              filled: true,
            ),
            labelText: "Risk Severity",
            results: HazardReportWidget.formResult,
            str: 'risk_severity',
          ),
        ),
        Flexible(
          flex: 8,
          child: CustomTextFormField(
            labelText: "Interim Comment",
            str: "interim_comment",
            results: HazardReportWidget.formResult,
          ),
        ),
      ],
    );
  }
}

class SeverityOfConsequenceWidget extends StatelessWidget {
  const SeverityOfConsequenceWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = [
      {
        "definition": "Negligible",
        "meaning": "Nuisance of little consequences",
        "value": "1"
      },
      {
        "definition": "Minor",
        "meaning": "Results in a minor incident",
        "value": "2"
      },
      {
        "definition": "Major",
        "meaning": "Serious incident or injury",
        "value": "3"
      },
      {
        "definition": "Hazardous",
        "meaning": "Serious injury or major equipment damage",
        "value": "4"
      },
      {
        "definition": "Catastrophic",
        "meaning": "Results in an accident, death or equipment destroyed",
        "value": "5"
      },
    ];
    RiskSeverity riskSeverity = Provider.of<RiskSeverity>(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 500, maxWidth: 650),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              'What do you consider to be the worst possible consequence of this event happening? Click on the table below.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AbstractTable(
            data: data,
            getSelectedIndex: riskSeverity.getSelectedSeverity,
            setSelectedIndex: riskSeverity.setSelectedSeverity,
          ),
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
    List<Map<String, dynamic>> data = [
      {
        "definition": "Extremely improbable",
        "meaning": "Almost inconceivable that the event will occur",
        "value": "1"
      },
      {
        "definition": "Improbable",
        "meaning": "Very unlikely to occur",
        "value": "2"
      },
      {
        "definition": "Remote",
        "meaning": "Unlikely to occur but possible",
        "value": "3"
      },
      {
        "definition": "Occassional",
        "meaning": "Likely to occur sometimes",
        "value": "4"
      },
      {
        "definition": "Frequent",
        "meaning": "Likely to occur many time",
        "value": "5"
      },
    ];
    RiskSeverity riskSeverity = Provider.of<RiskSeverity>(context);
    return Container(
      constraints: const BoxConstraints(minWidth: 500, maxWidth: 650),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: const Text(
              'In your opinion, what is the likelihood of the occurrence happening again? Click on the table below.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          AbstractTable(
            data: data,
            getSelectedIndex: riskSeverity.getSelectedLikelihood,
            setSelectedIndex: riskSeverity.setSelectedLikelihood,
          )
        ],
      ),
    );
  }
}

class AbstractTable extends StatefulWidget {
  const AbstractTable(
      {super.key,
      required this.data,
      required this.setSelectedIndex,
      required this.getSelectedIndex});
  final List<Map<String, dynamic>> data;
  final void Function(int) setSelectedIndex;
  final int Function() getSelectedIndex;

  @override
  State<AbstractTable> createState() => _AbstractTableState();
}

class _AbstractTableState extends State<AbstractTable> {
  List<DataColumn> get _columns {
    if (widget.data.isEmpty) {
      return [];
    }
    return widget.data.first.keys.map(
      (column) {
        return DataColumn(label: Text(column));
      },
    ).toList();
  }

  List<DataRow> get _rows {
    List<Map<String, dynamic>> rows = widget.data;
    return List.generate(
      rows.length,
      (index) {
        Map<String, dynamic> row = rows[index];
        return DataRow(
            cells: row.values.map(
              (column) {
                return DataCell(Text(column));
              },
            ).toList(),
            selected: index == widget.getSelectedIndex(),
            onSelectChanged: (value) {
              setState(() {
                widget.setSelectedIndex(index);
              });
            },
            color: WidgetStateColor.resolveWith(
              (states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.lightBlue;
                } else {
                  return Colors.transparent;
                }
              },
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      showCheckboxColumn: false,
      border: const TableBorder(
          horizontalInside: BorderSide(color: Colors.lightBlue)),
      decoration: BoxDecoration(border: Border.all(color: Colors.lightBlue)),
      columns: _columns,
      rows: _rows,
    );
  }
}

class RiskSeverity extends ChangeNotifier {
  int _selectedLikelihood = -1;
  int _selectedSeverity = -1;
  int getSelectedLikelihood() => _selectedLikelihood;
  int getSelectedSeverity() => _selectedSeverity;
  void setSelectedLikelihood(int value) {
    _selectedLikelihood = value;
    notifyListeners();
  }

  void setSelectedSeverity(int value) {
    _selectedSeverity = value;
    notifyListeners();
  }

  int get risk {
    return (_selectedLikelihood + 1) + (_selectedSeverity + 1);
  }

  Color? getColor() {
    if (_selectedLikelihood == 0 && _selectedSeverity == 3) {
      return Colors.green;
    } else if (risk > 0 && risk <= 4) {
      return Colors.green;
    } else if (risk > 4 && risk <= 7) {
      return Colors.amber;
    } else if (risk > 7 && risk < 11) {
      return Colors.red;
    } else {
      return Colors.transparent;
    }
    //return null;
  }

  String getText() {
    if (_selectedLikelihood == 0 && _selectedSeverity == 3) {
      return "Acceptable";
    } else if (risk > 0 && risk <= 4) {
      return "Acceptable";
    } else if (risk > 3 && risk <= 7) {
      return "Review";
    } else if (risk > 7 && risk < 11) {
      return "Unacceptable";
    } else {
      return "";
    }
  }
}
