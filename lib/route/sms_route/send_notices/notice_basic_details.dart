
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoticeBasicDetails extends StatefulWidget {
  const NoticeBasicDetails({
    super.key,
    required this.noticeBasicDetails,
    required this.viewMode,
    required this.editPermission,
  });

  final Map<String, dynamic> noticeBasicDetails;
  final bool viewMode;
  final bool editPermission;

  @override
  State<NoticeBasicDetails> createState() => _NoticeBasicDetailsState();
}

class _NoticeBasicDetailsState extends State<NoticeBasicDetails> {
  final TextEditingController _noticeDateController = TextEditingController();
  final TextEditingController _delineDateController = TextEditingController();

  @override
  void dispose() {
    _noticeDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> noticeBasicDetails = widget.noticeBasicDetails;
    bool editPermission = widget.editPermission;
    bool viewMode = widget.viewMode;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                labelText: 'Report Number',
                jsonKey: 'report_number',
                results: noticeBasicDetails,
                enabled: false,
              ),
            ),
            Expanded(
              child: SearchAuthorWidget(
                result: noticeBasicDetails,
                enabled: editPermission,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                labelText: "Notice Date",
                jsonKey: 'notce_at',
                results: noticeBasicDetails,
                enabled: !viewMode || editPermission,
                readOnly: true,
                controller: _noticeDateController,
              ),
            ),
            if (!viewMode || editPermission)
              IconButton(
                onPressed: () async {
                  noticeBasicDetails['notice_at'] = await showDatePicker(
                    context: context,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365 * 10)),
                    lastDate: DateTime.now(),
                    initialDate: noticeBasicDetails['notice_at'],
                  );
                  if (noticeBasicDetails['notice_at'] != null) {
                    _noticeDateController.text = DateFormat('dd/MM/yyyy')
                        .format(noticeBasicDetails['notice_at']);
                  } else {
                    _noticeDateController.text = "";
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.calendar_today),
              ),
            Expanded(
              child: CustomTextFormField(
                labelText: "Deadline Date",
                jsonKey: 'deadline_at',
                results: noticeBasicDetails,
                enabled: !viewMode || editPermission,
                readOnly: true,
                controller: _delineDateController,
              ),
            ),
            if (!viewMode || editPermission)
              IconButton(
                onPressed: () async {
                  noticeBasicDetails['deadline_at'] = await showDatePicker(
                    context: context,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365 * 10)),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365 * 10)),
                    initialDate: noticeBasicDetails['deadline_at'],
                  );
                  if (noticeBasicDetails['deadline_at'] != null) {
                    _delineDateController.text = DateFormat('dd/MM/yyyy')
                        .format(noticeBasicDetails['deadline_at']);
                  } else {
                    _delineDateController.text = "";
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.calendar_today),
              ),
          ],
        ),
        CustomTextFormField(
          labelText: 'Subject',
          jsonKey: 'subject',
          results: noticeBasicDetails,
          enabled: !viewMode || editPermission,
        ),
      ],
    );
  }
}
