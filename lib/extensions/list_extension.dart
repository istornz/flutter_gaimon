extension ListExtension on List<int> {
  int sum() {
    if (isEmpty) return 0;

    return reduce((value, element) => value + element);
  }
}
