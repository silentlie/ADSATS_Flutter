import 'package:flutter/material.dart';

import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'document_class.dart';

class DocumentsWidget extends StatelessWidget {
  const DocumentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          constraints: const BoxConstraints(maxWidth: 1536.0),
          child: PaginatedDataTableAsync(DocumentAPI())),
    );
  }
}
