import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'hazard_report_class.dart';
part 'hazard_report_tables.dart';

class HazardReportWidget extends StatelessWidget {
  const HazardReportWidget({super.key, required this.recepients});

  final Widget recepients;
  static Map<String, List<String>> formResult = {};

  @override
  Widget build(BuildContext context) {
    HazardReport hazardReport = HazardReport();

    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Form(
      child: Column(
        children: [
          const Text(
            'Send a notice - Hazard report',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          recepients,
          const Divider(),
          Row(
            children: [
              SearchAuthorWidget(
                customClass: hazardReport,
              ),
              const DateFormField(),
              const ReportType(),
            ],
          ),
          const Row(children: [
            SubjectTextField(),
            LocationTextField(),
          ]),
          const Row(
            children: [
              DescribeTextField(),
              MitigationColumn(),
            ],
          ),
          const Row(
            children: [
              LikelihoodofOccurrenceWidget(),
              SeverityOfConsequenceWidget()
            ],
          ),
          const RiskSeverityWidget(),
          Container(
            padding: const EdgeInsets.all(8),
            child: const TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text('Interim action/comments'),
              ),
            ),
          ),
          SearchFileWidget(fileNameResult: hazardReport.fileNameResult),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, // Align buttons to the right
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/sms');
                },
                label: const Text('Cancel'),
                icon: Icon(
                  Icons.mail,
                  color: colorScheme.onSecondary,
                ),
              ),
              // No save function for now
              // const SizedBox(width: 10),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     // Functionality for the second button
              //   },
              //   // Change text color
              //   label: const Text('Save'),
              //   icon: Icon(
              //     Icons.mail,
              //     color: colorScheme.onSecondary,
              //   ),
              // ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO:Functionality for the sending button
                },
                style: ButtonStyle(
                  // Change button background color
                  backgroundColor:
                      WidgetStateProperty.all<Color>(colorScheme.secondary),
                ),
                label: Text(
                  'Send Notification',
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
                icon: Icon(
                  Icons.mail,
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportType extends StatefulWidget {
  const ReportType({super.key});

  @override
  State<ReportType> createState() => _ReportTypeState();
}

enum ReportTypeRadio { open, confidential }

class _ReportTypeState extends State<ReportType> {
  ReportTypeRadio? _reportTypeRadio = ReportTypeRadio.open;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        children: [
          const Text(
            'Type of report:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Radio(
              value: ReportTypeRadio.open,
              groupValue: _reportTypeRadio,
              onChanged: (ReportTypeRadio? value) {
                setState(() {
                  _reportTypeRadio = value;
                });
              }),
          const Text(
            'Open',
          ),
          Radio(
              value: ReportTypeRadio.confidential,
              groupValue: _reportTypeRadio,
              onChanged: (ReportTypeRadio? value) {
                setState(() {
                  _reportTypeRadio = value;
                });
              }),
          const Text(
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

enum IncludeComment { yes, no }

class _MitigationState extends State<Mitigation> {
  IncludeComment? _includeComment = IncludeComment.no;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Include mitigation comment?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Radio(
            value: IncludeComment.yes,
            groupValue: _includeComment,
            onChanged: (IncludeComment? value) {
              setState(() {
                _includeComment = value;
              });
            }),
        const Text(
          'Yes',
        ),
        Radio(
            value: IncludeComment.no,
            groupValue: _includeComment,
            onChanged: (IncludeComment? value) {
              setState(() {
                _includeComment = value;
              });
            }),
        const Text(
          'No',
        ),
      ],
    );
  }
}
