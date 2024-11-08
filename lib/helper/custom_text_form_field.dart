part of 'search_file_widget.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      required this.labelText,
      this.jsonKey,
      this.isEmail = false,
      this.isFileName = false,
      required this.results,
      this.initialValue,
      this.controller,
      this.enabled = true,
      this.readOnly = false,
      this.maxLines,
      this.minLines = 1,
      this.decoration,
      this.padding = const EdgeInsets.all(8.0)});

  final String labelText;
  final String? initialValue;
  final TextEditingController? controller;
  final String? jsonKey;
  final bool enabled;
  final bool readOnly;
  final bool isEmail;
  final bool isFileName;
  final Map<String, dynamic> results;
  final int? maxLines;
  final int? minLines;
  final InputDecoration? decoration;
  final EdgeInsetsGeometry padding;

  String? validatorTextFormField(String? value) {
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    final RegExp fileNameRegExp =
        RegExp(r"""^[^~)(!'*<>:;,?"*|/]+\.[A-Za-z]{2,4}$""");
    if (!enabled) {
      return null;
    } else if (value == null || value.isEmpty) {
      return 'Please enter the ${labelText.toLowerCase()}';
    } else if (isEmail && !emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    } else if (isFileName && !fileNameRegExp.hasMatch(value)) {
      return 'Please enter a valid file name';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextFormField(
        decoration: decoration ??
            InputDecoration(
              labelText: labelText,
              hintText: 'Please enter the ${labelText.toLowerCase()}',
              border: const OutlineInputBorder(),
            ),
        textCapitalization: TextCapitalization.sentences,
        readOnly: readOnly,
        minLines: minLines,
        maxLines: maxLines,
        validator: validatorTextFormField,
        controller: controller,
        buildCounter: (context,
            {required currentLength, required isFocused, required maxLength}) {
          if (isFocused && !readOnly) {
            return Text(currentLength.toString());
          }
          return null;
        },
        onSaved: (value) {
          if (jsonKey != null){
            results[jsonKey!] = value!;
          }
        },
        initialValue: initialValue,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        enabled: enabled,
      ),
    );
  }
}
