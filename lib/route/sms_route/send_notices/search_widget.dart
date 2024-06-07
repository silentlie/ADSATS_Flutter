import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

// this widget is reference from search_anchor4.dart

class SearchWidget extends StatefulWidget {
  const SearchWidget(
      {super.key, required this.fileNameResult, required this.endpoint});
  final List<String> fileNameResult;
  final String endpoint;

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
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
      final restOperation = Amplify.API.get(widget.endpoint,
          apiName: 'AmplifyAviationAPI', queryParameters: queryParameters);

      final response = await restOperation.response;

      String jsonStr = response.decodeBody();
      Map<String, dynamic> rawData = jsonDecode(jsonStr);
      final rowsData = List<Map<String, dynamic>>.from(rawData["rows"]);
      debugPrint("finished fetch file name");
      return rowsData.map((row) {
        debugPrint(row['file_name'] as String);
        return row['file_name'] as String;
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

  @override
  Widget build(BuildContext context) {
    TextEditingController barController = TextEditingController();
    return Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(maxWidth: 400),
          child: SearchAnchor(
            builder: (context, controller) {
              return SearchBar(
                onTap: () {
                  controller.openView();
                },
                hintText: "Choose documents (Optional)",
                onChanged: (value) {
                  controller.openView();
                  controller.text = value;
                },
                controller: barController,
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(2),
                padding:
                    const WidgetStatePropertyAll(EdgeInsets.only(left: 20)),
                    
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
                        if (widget.fileNameResult.contains(option)) {
                          widget.fileNameResult.remove(option);
                        } else {
                          widget.fileNameResult.add(option);
                        }
                      });
                    },
                  );
                },
              );
              return _lastOptions;
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: widget.fileNameResult.map(
              (fileName) {
                return Chip(
                  label: Text(fileName),
                  onDeleted: () {
                    setState(() {
                      widget.fileNameResult.remove(fileName);
                    });
                  },
                );
              },
            ).toList(),
          ),
        )
      ],
    );
  }
}

const Duration debounceDuration = Duration(milliseconds: 500);

typedef _Debounceable<S, T> = Future<S?> Function(T parameter);

/// Returns a new function that is a debounced version of the given function.
///
/// This means that the original function will be called only after no calls
/// have been made for the given Duration.
_Debounceable<S, T> _debounce<S, T>(_Debounceable<S?, T> function) {
  _DebounceTimer? debounceTimer;

  return (T parameter) async {
    if (debounceTimer != null && !debounceTimer!.isCompleted) {
      debounceTimer!.cancel();
    }
    debounceTimer = _DebounceTimer();
    try {
      await debounceTimer!.future;
    } catch (error) {
      if (error is _CancelException) {
        return null;
      }
      rethrow;
    }
    return function(parameter);
  };
}

// A wrapper around Timer used for debouncing.
class _DebounceTimer {
  _DebounceTimer() {
    _timer = Timer(debounceDuration, _onComplete);
  }

  late final Timer _timer;
  final Completer<void> _completer = Completer<void>();

  void _onComplete() {
    _completer.complete();
  }

  Future<void> get future => _completer.future;

  bool get isCompleted => _completer.isCompleted;

  void cancel() {
    _timer.cancel();
    _completer.completeError(const _CancelException());
  }
}

// An exception indicating that the timer was canceled.
class _CancelException implements Exception {
  const _CancelException();
}
