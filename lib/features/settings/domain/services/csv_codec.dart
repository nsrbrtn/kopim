/// Минимальный CSV-кодек с поддержкой кавычек и переносов строк.
class CsvCodec {
  const CsvCodec._();

  static String encode(List<List<String>> rows) {
    final StringBuffer buffer = StringBuffer();
    for (int index = 0; index < rows.length; index += 1) {
      buffer.write(_encodeRow(rows[index]));
      if (index < rows.length - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  static List<List<String>> decode(String input) {
    final List<List<String>> rows = <List<String>>[];
    final StringBuffer field = StringBuffer();
    List<String> currentRow = <String>[];
    bool inQuotes = false;

    for (int index = 0; index < input.length; index += 1) {
      final String char = input[index];
      if (inQuotes) {
        if (char == '"') {
          final bool isEscaped =
              index + 1 < input.length && input[index + 1] == '"';
          if (isEscaped) {
            field.write('"');
            index += 1;
          } else {
            inQuotes = false;
          }
        } else {
          field.write(char);
        }
        continue;
      }

      if (char == '"') {
        inQuotes = true;
      } else if (char == ',') {
        currentRow.add(field.toString());
        field.clear();
      } else if (char == '\n') {
        currentRow.add(field.toString());
        field.clear();
        rows.add(currentRow);
        currentRow = <String>[];
      } else if (char == '\r') {
        continue;
      } else {
        field.write(char);
      }
    }

    if (inQuotes) {
      throw const FormatException(
        'Не удалось разобрать CSV: незакрытая кавычка.',
      );
    }

    if (field.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(field.toString());
      rows.add(currentRow);
    }

    return rows;
  }

  static String _encodeRow(List<String> row) {
    return row.map(_escapeCell).join(',');
  }

  static String _escapeCell(String value) {
    final bool needsQuotes =
        value.contains('"') ||
        value.contains(',') ||
        value.contains('\n') ||
        value.contains('\r') ||
        value.startsWith(' ') ||
        value.endsWith(' ');
    if (!needsQuotes) {
      return value;
    }
    final String escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}
