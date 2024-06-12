part of 'abstract_data_table_async.dart';

DataCell cellFor(Object? data) {
  Widget widget = const Text("");
  if (data == null) {
    widget = const Text("");
  } else if (data is DateTime) {
    widget = Text(
        '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}');
  } else if (data is bool) {
    widget = Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(20),
        color: data ? Colors.green : Colors.red,
      ),
      child: Center(child: Text(data ? "Yes" : "No")),
    );
  }
  // need to fix
  else if (data is List<String>) {
    widget = Row(
        children: data.map(
      (string) {
        return Text(string);
      },
    ).toList());
  } else {
    widget = Text(
      data.toString(),
      softWrap: false,
      overflow: TextOverflow.ellipsis,
    );
  }
  return DataCell(Center(child: widget));
}
