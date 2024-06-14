part of 'abstract_data_table_async.dart';

class CustomTableFilter {
  Map<String, dynamic> filterResults = {};
  Map<String, String> toJSON() {
    Map<String, String> tempJson = {};
    if (!filterResults.containsKey('archived')) {
      filterResults['archived'] = false;
    }
    filterResults.forEach((key, value) {
      if (value is bool) {
        tempJson[key] = value.toString();
      } else if (value is int) {
        tempJson[key] = value.toString();
      } else if (value is String) {
        key == 'search' ? tempJson[key] = '%$value%' : tempJson[key] = value;
      } else if (value is List<String> && value.isNotEmpty) {
        tempJson[key] = value.join(',');
      } else if (value is DateTimeRange) {
        tempJson[key] =
            "${value.start.toIso8601String()},${value.end.toIso8601String()}";
      }
    });
    return tempJson;
  }
}
