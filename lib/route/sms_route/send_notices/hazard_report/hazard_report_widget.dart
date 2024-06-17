import 'package:adsats_flutter/helper/search_file_widget.dart';
import 'package:adsats_flutter/route/sms_route/send_notices/hazard_report/hazard_report_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

part 'risk_serverity_tables.dart';

class HazardReportWidget extends StatefulWidget {
  const HazardReportWidget({
    super.key,
    this.noticeBasicDetails,
  });
  final Map<String, dynamic>? noticeBasicDetails;

  @override
  State<HazardReportWidget> createState() => _HazardReportWidgetState();
}

class _HazardReportWidgetState extends State<HazardReportWidget> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HazardReportNotifier>(
          create: (context) => HazardReportNotifier(),
        ),
        ChangeNotifierProvider<RiskSeverity>(
          create: (context) => RiskSeverity(),
        ),
      ],
      builder: (context, child) {
        return FutureBuilder(
          future: Provider.of<HazardReportNotifier>(context)
              .initialize(widget.noticeBasicDetails),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // loading widget can be customise
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // can make it into a error widget for more visualise
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return const Placeholder();
            }
          },
        );
      },
    );
  }
}
