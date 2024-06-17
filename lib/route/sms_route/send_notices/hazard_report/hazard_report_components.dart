import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';

class Mitigation extends StatefulWidget {
  const Mitigation({
    super.key,
    required this.hazardReportDetails,
  });
  final Map<String, dynamic> hazardReportDetails;
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
                  groupValue: widget.hazardReportDetails['included_comment'],
                  onChanged: (value) {
                    setState(() {
                      widget.hazardReportDetails['included_comment'] = value!;
                    });
                  }),
              const Text(
                'Yes',
              ),
              Radio(
                value: false,
                groupValue: widget.hazardReportDetails['included_comment'],
                onChanged: (value) {
                  setState(() {
                    widget.hazardReportDetails['included_comment'] = value!;
                  });
                },
              ),
              const Text(
                'No',
              ),
              const SizedBox(
                width: 20,
              ),
              const Text(
                'Type of report:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Radio(
                  value: true,
                  groupValue: widget.hazardReportDetails['report_type'],
                  onChanged: (value) {
                    setState(() {
                      widget.hazardReportDetails['report_type'] = value!;
                    });
                  }),
              const Text(
                'Open',
              ),
              Radio(
                value: false,
                groupValue: widget.hazardReportDetails['report_type'],
                onChanged: (value) {
                  setState(() {
                    widget.hazardReportDetails['report_type'] = value!;
                  });
                },
              ),
              const Text(
                'Confidential',
              ),
            ],
          ),
          if (widget.hazardReportDetails['included_comment'])
            CustomTextFormField(
              labelText:
                  'In your opinion, how could the hazard or event be mitigated? (optional)',
              jsonKey: 'mitigation',
              results: widget.hazardReportDetails,
              minLines: 3,
              maxLines: 6,
              padding: const EdgeInsets.only(),
            ),
        ],
      ),
    );
  }
}
