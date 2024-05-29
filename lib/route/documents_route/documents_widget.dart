import 'package:flutter/material.dart';

import 'package:adsats_flutter/abstract_data_table_async.dart';
import 'documents_classes.dart';

class DocumentsWidget extends StatelessWidget {
  const DocumentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1500.0),
        child: PaginatedDataTableAsync(DocumentAPI())
      ),
    );
  }
}