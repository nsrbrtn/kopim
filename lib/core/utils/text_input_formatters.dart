import 'package:flutter/services.dart';

TextInputFormatter digitsAndSeparatorsFormatter({
  Set<String> separators = const <String>{'.', ','},
}) {
  return TextInputFormatter.withFunction(
    (TextEditingValue oldValue, TextEditingValue newValue) {
      final String filtered = _filterDigitsAndSeparators(
        newValue.text,
        separators,
      );
      if (filtered == newValue.text && newValue.selection.isValid) {
        return newValue;
      }
      final int delta = newValue.text.length - filtered.length;
      int selectionIndex = newValue.selection.end - delta;
      if (selectionIndex < 0) {
        selectionIndex = 0;
      } else if (selectionIndex > filtered.length) {
        selectionIndex = filtered.length;
      }
      return TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: selectionIndex),
        composing: TextRange.empty,
      );
    },
  );
}

String _filterDigitsAndSeparators(String input, Set<String> separators) {
  if (input.isEmpty) {
    return input;
  }
  final StringBuffer buffer = StringBuffer();
  for (final int codeUnit in input.codeUnits) {
    final String char = String.fromCharCode(codeUnit);
    final bool isDigit = codeUnit >= 48 && codeUnit <= 57;
    if (isDigit || separators.contains(char)) {
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}
