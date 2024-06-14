part of 'search_file_widget.dart';

class SearchAuthorWidget extends StatefulWidget {
  const SearchAuthorWidget({super.key, required this.customClass});

  final dynamic customClass;
  @override
  State<SearchAuthorWidget> createState() => _SearchAuthorWidgetState();
}

class _SearchAuthorWidgetState extends State<SearchAuthorWidget> {
// the API call
  Future<Iterable<String>> fetchData(String search) async {
    if (search.isEmpty) {
      return const Iterable<String>.empty();
    }
    try {
      Map<String, String> queryParameters = {
        "offset": "0",
        "limit": "10",
        "search": "%$search%",
        "archived": "false",
      };
      debugPrint(queryParameters.toString());
      final restOperation = Amplify.API.get('/staff',
          apiName: 'AmplifyFilterAPI', queryParameters: queryParameters);

      final response = await restOperation.response;

      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);
      debugPrint("finished fetch file name");
      return rowsData.map((row) {
        return row['email'] as String;
      });
    } on ApiException catch (e) {
      debugPrint('GET call failed: $e');
      rethrow;
    } on Error catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  // The query currently being searched for. If null, there is no pending
  // request.
  String? _currentQuery;

  // The most recent suggestions received from the API.
  late Iterable<Widget> _lastOptions = <Widget>[];

  late final _Debounceable<Iterable<String>?, String> _debouncedSearch;

  // Calls the "remote" API to search with the given query. Returns null when
  // the call has been made obsolete.
  Future<Iterable<String>?> _search(String query) async {
    _currentQuery = query;

    // In a real application, there should be some error handling here.
    final Iterable<String> options = await fetchData(_currentQuery!);

    // If another search happened after this one, throw away these options.
    if (_currentQuery != query) {
      return null;
    }
    _currentQuery = null;

    return options;
  }

  @override
  void initState() {
    super.initState();
    _debouncedSearch = _debounce<Iterable<String>?, String>(_search);
  }

  TextEditingController barController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      constraints: const BoxConstraints(minWidth: 400, maxWidth: 700),
      padding: const EdgeInsets.all(8),
      child: SearchAnchor(
        builder: (context, controller) {
          return SearchBar(
            onTap: () {
              controller.openView();
            },
            hintText: "Specify author of this",
            onChanged: (value) {
              controller.openView();
              controller.text = value;
            },
            controller: barController,
            leading: const Icon(Icons.search),
            elevation: const WidgetStatePropertyAll(2),
            padding: const WidgetStatePropertyAll(EdgeInsets.only(left: 20)),
          );
        },
        viewConstraints: const BoxConstraints(maxHeight: 300),
        suggestionsBuilder: (context, controller) async {
          barController.text = controller.text;

          final List<String>? options =
              (await _debouncedSearch(controller.text))?.toList();
          if (options == null) {
            return _lastOptions;
          }
          _lastOptions = options.map(
            (option) {
              return ListTile(
                title: Text(option),
                onTap: () {
                  setState(() {
                    controller.closeView(null);
                    barController.text = option;
                    widget.customClass.author = option;
                  });
                },
              );
            },
          );
          return _lastOptions;
        },
      ),
    );
  }
}
