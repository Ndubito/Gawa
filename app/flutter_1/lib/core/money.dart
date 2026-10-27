/// Formats cents as whole shillings with thousands separators,
/// e.g. 400000 -> "4,000", 133333 -> "1,333".
String formatKesCents(int cents) {
  final whole = (cents / 100).round().toString();
  final buffer = StringBuffer();
  for (int i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return buffer.toString();
}
