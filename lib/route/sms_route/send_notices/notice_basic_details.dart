import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/recipients.dart';
import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NoticeBasicDetails extends StatefulWidget {
  const NoticeBasicDetails({super.key});
  static Map<String, dynamic> noticeBasicDetails = {};
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
    Map<String, dynamic> formResult = NoticeBasicDetails.noticeBasicDetails;
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    bool editMode = authNotifier.isAdmin || authNotifier.isEditor;
    return Column(
      children: [
        const RecepientsWidget(),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                labelText: 'Report Number',
                str: 'report_number',
                results: formResult,
                enabled: false,
              ),
            ),
            Expanded(
              child: SearchAuthorWidget(
                result: formResult,
                enabled: editMode,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomTextFormField(
                labelText: "Notice Date",
                str: 'notce_at',
                results: formResult,
                enabled: true,
                readOnly: true,
                controller: _noticeDateController,
              ),
            ),
            IconButton(
              onPressed: () async {
                formResult['notice_at'] = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: formResult['notice_at'],
                );
                if (formResult['notice_at'] != null) {
                  _noticeDateController.text =
                      DateFormat('dd/MM/yyyy').format(formResult['notice_at']);
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
                str: 'deadline_at',
                results: formResult,
                enabled: true,
                readOnly: true,
                controller: _delineDateController,
              ),
            ),
            IconButton(
              onPressed: () async {
                formResult['deadline_at'] = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  initialDate: formResult['deadline_at'],
                );
                if (formResult['deadline_at'] != null) {
                  _delineDateController.text = DateFormat('dd/MM/yyyy')
                      .format(formResult['deadline_at']);
                } else {
                  _delineDateController.text = "";
                }
                setState(() {});
              },
              icon: const Icon(Icons.calendar_today),
            ),
          ],
        )
      ],
    );
  }
}
