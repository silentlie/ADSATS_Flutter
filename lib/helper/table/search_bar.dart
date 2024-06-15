part of 'abstract_data_table_async.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget(
      {super.key, required this.filters, required this.refreshDatasource});
  final CustomTableFilter filters;
  final Function refreshDatasource;
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _textEditingController.text = widget.filters.filterResults['search'] ?? '';
    return SearchBar(
      elevation: const WidgetStatePropertyAll(1),
      constraints: const BoxConstraints(
        minHeight: 32,
        maxWidth: 200,
      ),
      controller: _textEditingController,
      onSubmitted: (value) {
        widget.filters.filterResults['search'] = value;
        widget.refreshDatasource();
      },
      trailing: const [Icon(Icons.search)],
    );
  }
}
