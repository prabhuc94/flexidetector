import 'dart:async';
import 'dart:ui';

class Debouncer {
  Debouncer._();

  static const DEFAULT_DURATION = Duration(minutes: 1);
  static final Debouncer instance = Debouncer._();

  Timer? _timer;
  void run(VoidCallback callback, {Duration duration = DEFAULT_DURATION}) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }
}

final debounce = Debouncer.instance;