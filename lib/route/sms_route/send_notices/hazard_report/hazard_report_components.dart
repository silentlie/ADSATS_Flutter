import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComponentsWidget extends StatefulWidget {
  const ComponentsWidget({
    super.key,
    required this.hazardReportDetails,
    required this.enabled,
  });
  final Map<String, dynamic> hazardReportDetails;
  final bool enabled;
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
                  if (widget.enabled) {
                    setState(() {
                      widget.hazardReportDetails['included_comment'] = value!;
                    });
                  }
                },
              ),
              const Text(
                'Yes',
              ),
              Radio(
                value: false,
                groupValue: widget.hazardReportDetails['included_comment'],
                onChanged: (value) {
                  if (widget.enabled) {
                    setState(() {
                      widget.hazardReportDetails['included_comment'] = value!;
                    });
                  }
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
                  if (widget.enabled) {
                    setState(() {
                      widget.hazardReportDetails['report_type'] = value!;
                    });
                  }
                },
              ),
              const Text(
                'Open',
              ),
              Radio(
                value: false,
                groupValue: widget.hazardReportDetails['report_type'],
                onChanged: (value) {
                  if (widget.enabled) {
                    setState(() {
                      widget.hazardReportDetails['report_type'] = value!;
                    });
                  }
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
              padding: const EdgeInsets.only(),
              enabled: widget.enabled,
            ),
        ],
      ),
    );
  }
}

class ResolveWidget extends StatefulWidget {
  const ResolveWidget({
    super.key,
    required this.noticeBasicDetails,
    required this.enabled,
  });
  final Map<String, dynamic> noticeBasicDetails;
  final bool enabled;
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
                  if (widget.enabled) {
                    setState(() {
                      widget.noticeBasicDetails['resolved'] = value!;
                    });
                  }
                },
              ),
              const Text(
                'Resolved',
              ),
              Radio(
                value: false,
                groupValue: widget.noticeBasicDetails['resolved'],
                onChanged: (value) {
                  if (widget.enabled) {
                    setState(() {
                      widget.noticeBasicDetails['resolved'] = value!;
                    });
                  }
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
              enabled: widget.enabled,
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
  late Map<String, dynamic> hazardReportDetails;
  late bool editPermission;

  @override
  void initState() {
    hazardReportDetails = widget.hazardReportDetails;
    editPermission = widget.editPermission;
    if (hazardReportDetails['review_at'] != null) {
      _reviewDateController.text =
          DateFormat('dd/MM/yyyy').format(hazardReportDetails['review_at']);
    } else {
      _reviewDateController.text = "";
    }
    super.initState();
  }

  @override
  void dispose() {
    _reviewDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: CustomTextFormField(
            labelText: "Interim Comment",
            jsonKey: "interim_comment",
            results: hazardReportDetails,
            enabled: editPermission,
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
        ),
        if (editPermission)
          IconButton(
            onPressed: () async {
              hazardReportDetails['review_at'] = await showDatePicker(
                context: context,
                firstDate:
                    DateTime.now().subtract(const Duration(days: 365 * 10)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
                initialDate: hazardReportDetails['review_at'],
              );
              if (hazardReportDetails['review_at'] != null) {
                _reviewDateController.text = DateFormat('dd/MM/yyyy')
                    .format(hazardReportDetails['review_at']);
              } else {
                _reviewDateController.text = "";
              }
              setState(() {});
            },
            icon: const Icon(Icons.calendar_today),
          ),
      ],
    );
  }
}
