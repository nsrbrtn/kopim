/// Parses user-provided balance input into a [double].
///
/// Accepts both comma and dot as decimal separators. Returns `null` if the
/// value cannot be parsed. Empty input is treated as zero to match the
/// behaviour of the add/edit account forms where balance is optional.
double? parseBalanceInput(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return 0;
  }

  final String normalized = trimmed.replaceAll(',', '.');
  return double.tryParse(normalized);
}
