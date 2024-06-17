part of 'safety_notice_widget.dart';

class ResolveWidget extends StatefulWidget {
  const ResolveWidget({super.key, required this.noticeBasicDetails});
  final Map<String, dynamic> noticeBasicDetails;
  @override
  State<ResolveWidget> createState() => _ResolveWidgetState();
}

class _ResolveWidgetState extends State<ResolveWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.noticeBasicDetails['resovled'] == null) {
      widget.noticeBasicDetails['resovled'] = false;
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
                  groupValue: widget.noticeBasicDetails['resovled'],
                  onChanged: (value) {
                    setState(() {
                      widget.noticeBasicDetails['resovled'] = value!;
                    });
                  }),
              const Text(
                'Resolved',
              ),
              Radio(
                value: false,
                groupValue: widget.noticeBasicDetails['resovled'],
                onChanged: (value) {
                  setState(() {
                    widget.noticeBasicDetails['resovled'] = value!;
                  });
                },
              ),
              const Text(
                'Pending',
              ),
            ],
          ),
          if (!widget.noticeBasicDetails['resovled'])
            CustomTextFormField(
              labelText: 'Reason why it is not resolved',
              jsonKey: 'reason',
              results: widget.noticeBasicDetails,
              minLines: 3,
              padding: const EdgeInsets.only(),
            ),
        ],
      ),
    );
  }
}
