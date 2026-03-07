extension StringNumeralExtension on String {
  /// Converts Eastern Arabic digits (١٢٣٤٥٦٧٨٩٠) to Western Arabic digits (1234567890).
  String toWesternDigits() {
    const easternToWestern = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    return split('').map((char) => easternToWestern[char] ?? char).join();
  }
}
