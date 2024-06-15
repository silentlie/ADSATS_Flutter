part of 'search_file_widget.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      required this.labelText,
      required this.str,
      this.isEmail = false,
      this.isFileName = false,
      required this.results,
      this.initialValue,
      this.enabled = true,
      this.maxLines,
      this.minLines = 1});

  final String labelText;
  final String? initialValue;
  final String str;
  final bool enabled;
  final bool isEmail;
  final bool isFileName;
  final Map<String, dynamic> results;
  final int? maxLines;
  final int? minLines;

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
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          hintText: 'Please enter the ${labelText.toLowerCase()}',
          border:
              enabled ? const OutlineInputBorder() : const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.sentences,
        readOnly: false,
        minLines: minLines,
        maxLines: maxLines,
        validator: validatorTextFormField,
        buildCounter: (context,
            {required currentLength, required isFocused, required maxLength}) {
          if (isFocused) {
            return Text(currentLength.toString());
          }
          return null;
        },
        onSaved: (value) {
          results[str] = value!;
        },
        initialValue: initialValue,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        enabled: enabled,
      ),
    );
  }
}
