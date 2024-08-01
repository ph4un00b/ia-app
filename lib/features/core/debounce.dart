import 'dart:async';

class Debounce {
  final int ms;
  Timer? _timer;

  Debounce({
    required this.ms,
  });

  void callback(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: ms), action);
  }
}
