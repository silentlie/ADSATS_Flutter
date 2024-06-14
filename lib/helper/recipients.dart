import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:wrapfit/wrapfit.dart';

class RecepientsWidget extends StatelessWidget {
  const RecepientsWidget({super.key});

  static Map<String, List<String>> recipientsResult = {};

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = AuthNotifier();
    return Wrap2(
      children: [
        Wrapped(
          fit: WrapFit.runLoose,
          child: Container(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 450),
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
        ),
        Wrapped(
          fit: WrapFit.runLoose,
          child: Container(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 450),
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
        ),
        Wrapped(
          fit: WrapFit.runLoose,
          child: Container(
            constraints: const BoxConstraints(minWidth: 400, maxWidth: 450),
            child: MultiSelect(
              buttonText: const Text("Aircraft"),
              title: const Text("Aircraft"),
              onConfirm: (selectedOptions) {
                recipientsResult['aircraft'] =
                    List<String>.from(selectedOptions);
              },
              items: authNotifier.aircraft.map(
                (aircraft) {
                  return MultiSelectItem(aircraft, aircraft);
                },
              ).toList(),
              initialValue: recipientsResult['aircraft'] ?? [],
            ),
          ),
        )
      ],
    );
  }
}
