extension TimeExtension on double {
  /// Converts a time in seconds to milliseconds
  int toMs() {
    return (this * 1000).round();
  }
}
