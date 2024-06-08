part of 'abstract_data_table_async.dart';

class CustomTableFilter {
  String? search;

  Map<String, List<String>> filterResult = {};

  Map<String, String> toJSON() {
    Map<String, String> tempJson = {};
    if (search != null) {
      tempJson["search"] = "%${search!}%";
    }
    if (filterResult.isNotEmpty) {
      tempJson.addAll(
        filterResult.map(
          (key, value) {
            return MapEntry(
              key,
              value.join(','),
            );
          },
        ),
      );
    }
    if (tempJson["archived"] == null) {
      tempJson["archived"] = false.toString();
    }

    return tempJson;
  }
}
