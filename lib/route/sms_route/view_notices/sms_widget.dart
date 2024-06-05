import 'package:flutter/material.dart';

import 'sms_classes.dart';
import 'package:adsats_flutter/data_table/abstract_data_table_async.dart';

class SMSWidget extends StatelessWidget {
  const SMSWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // specify max Width of document screen
        constraints: const BoxConstraints(maxWidth: 1500),
        child: PaginatedDataTableAsync(NoticeAPI()),
      ),
    );
  }
}

