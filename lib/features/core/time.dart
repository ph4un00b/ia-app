String formatTimestamp(DateTime dateTime) {
  return dateTime.toIso8601String().replaceAll(RegExp(r'[:\.-]'), '_');
}
