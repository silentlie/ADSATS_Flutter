import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class NoticeBasicDetails extends StatefulWidget {
  const NoticeBasicDetails({
    super.key,
    this.viewMode = false,
    required this.editPermission,
    required this.noticeBasicDetails,
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
  late Map<String, dynamic> noticeBasicDetails;
  late bool editPermission;
  late bool viewMode;
  @override
  void initState() {
    editPermission = widget.editPermission;
    viewMode = widget.viewMode;
    noticeBasicDetails = widget.noticeBasicDetails;
    if (noticeBasicDetails['notice_at'] != null) {
      _noticeDateController.text = DateFormat('dd/MM/yyyy')
          .format(DateTime.parse(noticeBasicDetails['notice_at']));
    } else {
      _noticeDateController.text = "";
    }
    if (noticeBasicDetails['deadline_at'] != null) {
      _delineDateController.text = DateFormat('dd/MM/yyyy')
          .format(DateTime.parse(noticeBasicDetails['deadline_at']));
    } else {
      _delineDateController.text = "";
    }
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _noticeDateController.dispose();
    _delineDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                labelText: 'Report Number',
                results: noticeBasicDetails,
                enabled: false,
                initialValue: noticeBasicDetails['notice_id'] ?? '',
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
                results: noticeBasicDetails,
                enabled: !viewMode || editPermission,
                readOnly: true,
                controller: _noticeDateController,
              ),
            ),
            if (!viewMode || editPermission)
              IconButton(
                onPressed: () async {
                  DateTime? temp = await showDatePicker(
                    context: context,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365 * 10)),
                    lastDate: DateTime.now(),
                    initialDate: noticeBasicDetails['notice_at'] == null
                        ? null
                        : DateTime.parse(noticeBasicDetails['notice_at']),
                  );
                  if (temp != null) {
                    _noticeDateController.text =
                        DateFormat('dd/MM/yyyy').format(temp);
                    noticeBasicDetails['notice_at'] = temp.toIso8601String();
                  } else {
                    _noticeDateController.text = "";
                    noticeBasicDetails['notice_at'] = null;
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.calendar_today),
              ),
            Expanded(
              child: CustomTextFormField(
                labelText: "Deadline Date",
                results: noticeBasicDetails,
                enabled: !viewMode || editPermission,
                readOnly: true,
                controller: _delineDateController,
              ),
            ),
            if (!viewMode || editPermission)
              IconButton(
                onPressed: () async {
                  DateTime? temp = await showDatePicker(
                    context: context,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365 * 10)),
                    lastDate:
                        DateTime.now().add(const Duration(days: 365 * 10)),
                    initialDate: noticeBasicDetails['deadline_at'] == null
                        ? null
                        : DateTime.parse(noticeBasicDetails['deadline_at']),
                  );
                  if (temp != null) {
                    _delineDateController.text =
                        DateFormat('dd/MM/yyyy').format(temp);
                    noticeBasicDetails['deadline_at'] = temp.toIso8601String();
                  } else {
                    _delineDateController.text = "";
                    noticeBasicDetails['deadline_at'] = null;
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.calendar_today),
              ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: CustomTextFormField(
                labelText: 'Subject',
                jsonKey: 'subject',
                results: noticeBasicDetails,
                enabled: !viewMode || editPermission,
                initialValue: noticeBasicDetails['subject'] ?? '',
              ),
            ),
            Flexible(
              child: MultiSelect(
                buttonText: const Text("Aircraft"),
                title: const Text("Aircraft"),
                onConfirm: (selectedOptions) {
                  if (!viewMode || editPermission) {
                    noticeBasicDetails['aircraft'] =
                        List<String>.from(selectedOptions);
                  }
                },
                items: Provider.of<AuthNotifier>(context, listen: false)
                    .aircraft
                    .map(
                  (aircraft) {
                    return MultiSelectItem(aircraft, aircraft);
                  },
                ).toList(),
                initialValue: noticeBasicDetails['aircraft'] ?? [],
              ),
            )
          ],
        ),
      ],
    );
  }
}
