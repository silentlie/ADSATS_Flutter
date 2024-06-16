import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

class RecepientsWidget extends StatelessWidget {
  const RecepientsWidget({super.key});

  static Map<String, List<String>> recipientsResult = {};
  bool validate() {
    bool isValidate = false;
    recipientsResult.forEach(
      (key, value) {
        if (value.isNotEmpty) {
          isValidate = true;
        }
      },
    );
    return isValidate;
  }
  
  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = Provider.of<AuthNotifier>(context);
    return Row(
      children: [
        Expanded(
          child: MultiSelect(
            buttonText: const Text(
              "Email",
            ),
            title: const Text(
              "Email",
            ),
            onConfirm: (selectedOptions) {
              recipientsResult['emails'] = List<String>.from(selectedOptions);
            },
            items: authNotifier.staff.map(
              (staff) {
                return MultiSelectItem(staff, staff);
              },
            ).toList(),
            initialValue: recipientsResult['emails'] ?? [],
          ),
        ),
        Expanded(
          child: MultiSelect(
            buttonText: const Text("Role"),
            title: const Text("Role"),
            onConfirm: (selectedOptions) {
              recipientsResult['roles'] = List<String>.from(selectedOptions);
            },
            items: authNotifier.roles.map(
              (role) {
                return MultiSelectItem(role, role);
              },
            ).toList(),
            initialValue: recipientsResult['roles'] ?? [],
          ),
        ),
        Expanded(
          child: MultiSelect(
            buttonText: const Text("Aircraft"),
            title: const Text("Aircraft"),
            onConfirm: (selectedOptions) {
              recipientsResult['aircraft'] = List<String>.from(selectedOptions);
            },
            items: authNotifier.aircraft.map(
              (aircraft) {
                return MultiSelectItem(aircraft, aircraft);
              },
            ).toList(),
            initialValue: recipientsResult['aircraft'] ?? [],
          ),
        )
      ],
    );
  }
}
