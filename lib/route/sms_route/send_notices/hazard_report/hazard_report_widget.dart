import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/notice_basic_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

part 'risk_serverity_tables.dart';

class HazardReportWidget extends StatelessWidget {
  const HazardReportWidget({
    super.key,
    this.viewMode = false,
    this.noticeID,
  });
  final int? noticeID;
  static Map<String, dynamic> noticeBasicDetails = {};
  static Map<String, dynamic> hazardReportDetails = {};
  static Map<String, dynamic> recipients = {};
  final bool viewMode;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // Access color scheme
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    bool editPermission = authNotifier.isAdmin || authNotifier.isEditor;
    noticeBasicDetails['file_names'] = <String>[];
    hazardReportDetails['included_comment'] = false;
    hazardReportDetails['report_type'] = true;
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
            NoticeBasicDetails(noticeBasicDetails: HazardReportWidget.noticeBasicDetails, viewMode: viewMode, editPermission: editPermission,),
            CustomTextFormField(
              labelText: 'Location',
              jsonKey: 'location',
              results: noticeBasicDetails,
            ),
            const ReportType(),
            CustomTextFormField(
              labelText: 'Describe the Hazard or the Event',
              jsonKey: 'describe',
              results: noticeBasicDetails,
              minLines: 5,
              maxLines: 10,
            ),
            const Mitigation(),
            const RiskSeverityWidget(),
            Container(
              padding: const EdgeInsets.all(8),
              child: SearchFileWidget(
                fileNames: noticeBasicDetails['file_names'],
              ),
            ),
            if (viewMode)
              RecepientsWidget(
                recipients: recipients,
              ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
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
              groupValue: HazardReportWidget.hazardReportDetails['report_type'],
              onChanged: (value) {
                setState(() {
                  HazardReportWidget.hazardReportDetails['report_type'] =
                      value!;
                });
              }),
          const Text(
            'Open',
          ),
          Radio(
            value: false,
            groupValue: HazardReportWidget.hazardReportDetails['report_type'],
            onChanged: (value) {
              setState(() {
                HazardReportWidget.hazardReportDetails['report_type'] = value!;
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Include mitigation comment?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Radio(
                  value: true,
                  groupValue: HazardReportWidget
                      .hazardReportDetails['included_comment'],
                  onChanged: (value) {
                    setState(() {
                      HazardReportWidget
                          .hazardReportDetails['included_comment'] = value!;
                    });
                  }),
              const Text(
                'Yes',
              ),
              Radio(
                value: false,
                groupValue:
                    HazardReportWidget.hazardReportDetails['included_comment'],
                onChanged: (value) {
                  setState(() {
                    HazardReportWidget.hazardReportDetails['included_comment'] =
                        value!;
                  });
                },
              ),
              const Text(
                'No',
              ),
            ],
          ),
          if (HazardReportWidget.hazardReportDetails['included_comment'])
            CustomTextFormField(
              labelText:
                  'In your opinion, how could the hazard or event be mitigated? (optional)',
              jsonKey: 'mitigation',
              results: HazardReportWidget.noticeBasicDetails,
              minLines: 3,
              maxLines: 6,
              padding: const EdgeInsets.only(),
            ),
        ],
      ),
    );
  }
}
