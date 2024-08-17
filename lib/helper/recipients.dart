import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class RecepientsWidget extends StatelessWidget {
  const RecepientsWidget({
    super.key,
    required this.recipients,
  });

  final Map<String, dynamic> recipients;

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 8),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Add recipients by:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: MultiSelect(
                buttonText: const Text(
                  "Aircraft",
                ),
                title: const Text(
                  "Aircraft",
                ),
                onConfirm: (selectedOptions) {
                  recipients['aircraft'] = List<String>.from(selectedOptions);
                },
                items: authNotifier.aircraftCache.entries.map(
                  (entry) {
                    return MultiSelectItem(
                      entry.key,
                      entry.value,
                    );
                  },
                ).toList(),
                initialValue: recipients['aircraft'] ?? [],
              ),
            ),
            Expanded(
              child: MultiSelect(
                buttonText: const Text(
                  "Role",
                ),
                title: const Text(
                  "Role",
                ),
                onConfirm: (selectedOptions) {
                  recipients['roles'] = List<String>.from(selectedOptions);
                },
                items: authNotifier.rolesCache.entries.map(
                  (entry) {
                    return MultiSelectItem(
                      entry.key,
                      entry.value,
                    );
                  },
                ).toList(),
                initialValue: recipients['roles'] ?? [],
              ),
            ),
            Expanded(
              child: MultiSelect(
                buttonText: const Text(
                  "Email",
                ),
                title: const Text(
                  "Email",
                ),
                onConfirm: (selectedOptions) {
                  recipients['staff'] = List<String>.from(selectedOptions);
                },
                initialValue: recipients['staff'] ?? [],
                items: authNotifier.staffCache.entries.map(
                  (entry) {
                    return MultiSelectItem(
                      entry.key,
                      entry.value,
                    );
                  },
                ).toList(),
              ),
            )
          ],
        ),
      ],
    );
  }
}
