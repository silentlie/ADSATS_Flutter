import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:wrapfit/wrapfit.dart';

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
      child: ChangeNotifierProvider(
        create: (context) => RiskSeverity(),
        child: Column(
          children: [
            const Text(
              'Hazard report',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Add recipients by:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            recepients,
            const Divider(),
            Wrap2(
              children: [
                Wrapped(
                    fit: WrapFit.runLoose,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 400, maxWidth: 700),
                      child: SearchAuthorWidget(customClass: hazardReport),
                    )),
                Wrapped(
                    fit: WrapFit.runLoose,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      constraints:
                          const BoxConstraints(minWidth: 200, maxWidth: 325),
                      child: const TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Report Number'),
                            enabled: false),
                      ),
                    )),
                const Wrapped(
                  fit: WrapFit.runLoose,
                  child: DateFormField(),
                )
              ],
            ),
            // const SubjectTextField(),
            const Wrap2(children: [
              SubjectTextField(),
              LocationTextField(),
              ReportType()
            ]),
            const Wrap2(
              children: [
                DescribeTextField(),
                MitigationColumn(),
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
    return Container(
      height: 60,
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 310),
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
        Row(
          children: [
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
          ],
        ),
        Row(
          children: [
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
        ),
      ],
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
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 650),
      padding: const EdgeInsets.all(5),
      child: const Column(
        children: [
          Mitigation(),
          MitigationTextField(),
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
    return Wrapped(
      fit: WrapFit.runLoose,
      child: Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 650),
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
    return Container(
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
      padding: const EdgeInsets.all(5),
      child: const TextField(
        decoration: InputDecoration(
          label: Text('Location'),
          border: OutlineInputBorder(),
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
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
      padding: const EdgeInsets.all(5),
      child: const TextField(
        decoration: InputDecoration(
            label: Text('Subject'), border: OutlineInputBorder()),
      ),
    );
  }
}

class DateFormField extends StatelessWidget {
  const DateFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 325),
      // constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.all(5),
      child: InputDatePickerFormField(
        initialDate: DateTime.timestamp(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      ),
    );
  }
}
