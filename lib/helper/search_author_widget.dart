part of 'search_file_widget.dart';

class SearchAuthorWidget extends StatelessWidget {
  const SearchAuthorWidget(
      {super.key, required this.result, this.enabled = true});
  final Map<String, dynamic> result;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);
    result['author'] = authNotifier.email;
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu(
        dropdownMenuEntries: authNotifier.staff.map(
          (staff) {
            return DropdownMenuEntry(label: staff, value: staff);
          },
        ).toList(),
        enableFilter: true,
        enabled: enabled,
        menuHeight: 200,
        initialSelection: result['author'],
        label: const Text("Author"),
        hintText: "Please enter the author",
        leadingIcon: const Icon(Icons.search),
        onSelected: (value) {
          result['author'] = value!;
        },
        expandedInsets: EdgeInsets.zero,
      ),
    );
  }
}
