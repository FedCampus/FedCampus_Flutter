/// Helper functions for manupulating collections.
/// Since there is no built-in implementation of combinations in Dart, I do it myself.
library;
// ignore_for_file: avoid_print

/// Give all possible combinations of [items] with length [combinationLength],
///
/// ```dart
///  List<int> numbers = [1, 2, 3, 4];
///  int combinationLength = 3;
///
///  var combination = combinations(numbers, combinationLength);
///
///  for (var comb in combination) {
///    print(comb);
///  }
/// ```
List<List<T>> combinations<T>(List<T> items, int combinationLength) {
  if (combinationLength == 0 || items.isEmpty) {
    return [];
  }

  List<List<T>> result = [];
  List<T> currentCombination = [];

  void generateCombinations(int startIndex, int remainingLength) {
    if (remainingLength == 0) {
      result.add(List<T>.from(currentCombination));
      return;
    }

    for (int i = startIndex; i <= items.length - remainingLength; i++) {
      currentCombination.add(items[i]);
      generateCombinations(i + 1, remainingLength - 1);
      currentCombination.removeLast();
    }
  }

  generateCombinations(0, combinationLength);

  return result;
}

Iterable<List<T>> zip<T>(Iterable<T> iterable1, Iterable<T> iterable2) sync* {
  final iterator1 = iterable1.iterator;
  final iterator2 = iterable2.iterator;

  while (iterator1.moveNext() && iterator2.moveNext()) {
    yield [iterator1.current, iterator2.current];
  }
}

// test client
void main() {
  List<int> numbers = [1, 2, 3, 4];
  int combinationLength = 3;

  var combination = combinations(numbers, combinationLength);

  for (var comb in combination) {
    print(comb);
  }
}
