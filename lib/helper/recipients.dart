import 'package:adsats_flutter/amplify/auth.dart';
import 'package:adsats_flutter/helper/table/abstract_data_table_async.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class RecepientsWidget extends StatelessWidget {
  const RecepientsWidget({super.key});

  static Map<String, List<String>> recipientsResult = {};

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier = AuthNotifier();
    List<Widget> filterContent = [
      Flexible(
        child: MultiSelect(
          buttonText: const Text(
            "Add recipient",
          ),
          title: const Text(
            "Add recipients",
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
      Flexible(
        child: MultiSelect(
          buttonText: const Text("Add roles"),
          title: const Text("Add roles"),
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
<<<<<<< HEAD
      Flexible(
        child: MultiSelect(
          buttonText: const Text("Add aircrafts"),
          title: const Text("Add aircrafts"),
          onConfirm: (selectedOptions) {
            recipientsResult['aircrafts'] = List<String>.from(selectedOptions);
=======
      MultiSelect(
        buttonText: const Text("Add aircrafts"),
        title: const Text("Add aircrafts"),
        onConfirm: (selectedOptions) {
          recipientsResult['aircrafts'] = List<String>.from(selectedOptions);
        },
        items: authNotifier.aircraft.map(
          (aircraft) {
            return MultiSelectItem(aircraft, aircraft);
>>>>>>> 7d4b5c42daf2d1d7b21ac6cfe36468f8f4add877
          },
          items: authNotifier.aircrafts.map(
            (aircraft) {
              return MultiSelectItem(aircraft, aircraft);
            },
          ).toList(),
          initialValue: recipientsResult['aircrafts'] ?? [],
        ),
      )
    ];
    // return column with filter content
    return Row(
      children: filterContent,
    );
  }
}
