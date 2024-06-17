import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';

class ComponentsWidget extends StatefulWidget {
  const ComponentsWidget({
    super.key,
    required this.hazardReportDetails,
  });
  final Map<String, dynamic> hazardReportDetails;
  @override
  State<ComponentsWidget> createState() => _ComponentsWidgetState();
}

class _ComponentsWidgetState extends State<ComponentsWidget> {
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
                  'In your opinion, how could the hazard or event be mitigated?',
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

class ResolveWidget extends StatefulWidget {
  const ResolveWidget({super.key, required this.noticeBasicDetails});
  final Map<String, dynamic> noticeBasicDetails;
  @override
  State<ResolveWidget> createState() => _ResolveWidgetState();
}

class _ResolveWidgetState extends State<ResolveWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.noticeBasicDetails['resolved'] == null) {
      widget.noticeBasicDetails['resolved'] = false;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Radio(
                  value: true,
                  groupValue: widget.noticeBasicDetails['resolved'],
                  onChanged: (value) {
                    setState(() {
                      widget.noticeBasicDetails['resolved'] = value!;
                    });
                  }),
              const Text(
                'Resolved',
              ),
              Radio(
                value: false,
                groupValue: widget.noticeBasicDetails['resolved'],
                onChanged: (value) {
                  setState(() {
                    widget.noticeBasicDetails['resolved'] = value!;
                  });
                },
              ),
              const Text(
                'Pending',
              ),
            ],
          ),
          if (!widget.noticeBasicDetails['resolved'])
            CustomTextFormField(
              labelText: 'Reason why it is not resolved',
              jsonKey: 'pending_comments',
              results: widget.noticeBasicDetails,
              minLines: 3,
              maxLines: 6,
              padding: const EdgeInsets.only(),
            ),
        ],
      ),
    );
  }
}

class InterimCommentAndReviewDate extends StatefulWidget {
  const InterimCommentAndReviewDate({
    super.key,
    required this.editPermission,
    required this.hazardReportDetails,
  });
  final Map<String, dynamic> hazardReportDetails;
  final bool editPermission;
  @override
  State<InterimCommentAndReviewDate> createState() =>
      _InterimCommentAndReviewDateState();
}

class _InterimCommentAndReviewDateState
    extends State<InterimCommentAndReviewDate> {
  final TextEditingController _reviewDateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> hazardReportDetails = widget.hazardReportDetails;
    bool editPermission = widget.editPermission;
    return Row(
      children: [
        Flexible(
          child: CustomTextFormField(
            labelText: "Interim Comment",
            jsonKey: "interim_comment",
            results: hazardReportDetails,
          ),
        ),
        Flexible(
          child: CustomTextFormField(
            labelText: "Review Date",
            results: hazardReportDetails,
            enabled: editPermission,
            readOnly: true,
            controller: _reviewDateController,
          ),
        )
      ],
    );
  }
}
