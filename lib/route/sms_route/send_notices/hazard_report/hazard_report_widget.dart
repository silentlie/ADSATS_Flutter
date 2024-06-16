import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

part 'risk_serverity_tables.dart';

class HazardReportWidget extends StatelessWidget {
  const HazardReportWidget({
    super.key,
  });

  static Map<String, List<String>> formResult = {};

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: formKey,
      child: ChangeNotifierProvider(
        create: (context) => RiskSeverity(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: const Text(
                'Hazard report',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            const NoticeBasicDetails(),
            Row(
              children: [
                Flexible(
                  flex: 7,
                  child: CustomTextFormField(
                    labelText: 'Subject',
                    jsonKey: 'subject',
                    results: formResult,
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: CustomTextFormField(
                    labelText: 'Location',
                    jsonKey: 'location',
                    results: formResult,
                  ),
                ),
                const ReportType(),
              ],
            ),
            CustomTextFormField(
              labelText: 'Describe the Hazard or the Event',
              jsonKey: 'describe',
              results: formResult,
              minLines: 5,
              maxLines: 10,
            ),
            const Mitigation(),
            CustomTextFormField(
              labelText:
                  'In your opinion, how could the hazard or event be mitigated? (optional)',
              jsonKey: 'mitigation',
              results: formResult,
              minLines: 3,
              maxLines: 6,
            ),
            const RiskSeverityWidget(),
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
  static bool reportTypeRadio = true;
  @override
  State<ReportType> createState() => _ReportTypeState();
}

enum ReportTypeRadio { open, confidential }

class _ReportTypeState extends State<ReportType> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text(
            'Type of report:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Radio(
              value: true,
              groupValue: ReportType.reportTypeRadio,
              onChanged: (value) {
                setState(() {
                  ReportType.reportTypeRadio = value!;
                });
              }),
          const Text(
            'Open',
          ),
          Radio(
            value: false,
            groupValue: ReportType.reportTypeRadio,
            onChanged: (value) {
              setState(() {
                ReportType.reportTypeRadio = value!;
              });
            },
          ),
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

class _MitigationState extends State<Mitigation> {
  bool _includeComment = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Include mitigation comment?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Radio(
            value: true,
            groupValue: _includeComment,
            onChanged: (value) {
              setState(() {
                _includeComment = value!;
              });
            }),
        const Text(
          'Yes',
        ),
        Radio(
            value: false,
            groupValue: _includeComment,
            onChanged: (value) {
              setState(() {
                _includeComment = value!;
              });
            }),
        const Text(
          'No',
        ),
      ],
    );
  }
}
