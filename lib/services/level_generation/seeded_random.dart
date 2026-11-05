
class SeededRandom {
  int _state;

  SeededRandom(int seed) : _state = seed & 0xFFFFFFFF;

  double nextDouble() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;

    var value = _state;

    value = _multiply32(
      value ^ (value >> 15),
      value | 1,
    );

    value ^= (value + _multiply32(
      value ^ (value >> 7),
      value | 61,
    )) & 0xFFFFFFFF;

    value &= 0xFFFFFFFF;
    value ^= value >> 14;

    return (value & 0xFFFFFFFF) / 4294967296.0;
  }

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'Must be greater than zero.');
    }

    return (nextDouble() * max).floor();
  }

  int _multiply32(int a, int b) {
    return (a * b) & 0xFFFFFFFF;
  }

  void shuffle<T>(List<T> items) {
    for (var i = items.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);

      final temp = items[i];
      items[i] = items[j];
      items[j] = temp;
    }
  }
}
