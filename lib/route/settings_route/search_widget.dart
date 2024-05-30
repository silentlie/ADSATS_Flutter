import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({super.key});

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      constraints: const BoxConstraints(
        maxWidth: 360,
      ),
      leading: const Icon(Icons.search),
      controller: _textEditingController,
    );
  }
}
