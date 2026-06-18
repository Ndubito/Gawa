/// Normalizes Kenyan phone input to E.164 (+254...), which is what
/// Firebase stores and the backend expects.
///
/// Accepts "0712345678", "712345678", "254712345678" or "+254712345678".
/// Returns null when the input can't be a valid Kenyan number.
String? normalizeKenyanPhone(String input) {
  final cleaned = input.replaceAll(RegExp(r'[\s\-()]'), '');

  String digits;
  if (cleaned.startsWith('+254')) {
    digits = cleaned.substring(4);
  } else if (cleaned.startsWith('254')) {
    digits = cleaned.substring(3);
  } else if (cleaned.startsWith('0')) {
    digits = cleaned.substring(1);
  } else {
    digits = cleaned;
  }

  // Kenyan subscriber numbers: 9 digits starting with 7 (mobile) or 1
  if (!RegExp(r'^[71]\d{8}$').hasMatch(digits)) return null;

  return '+254$digits';
}
