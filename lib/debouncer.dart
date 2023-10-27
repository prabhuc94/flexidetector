import 'dart:async';
import 'dart:ui';

class Debounce {
  Debounce._();

  static const DEFAULT_DURATION = Duration(minutes: 1);
  static final Debounce instance = Debounce._();

  Timer? _timer;
  void run(VoidCallback callback, {Duration duration = DEFAULT_DURATION}) {
    if (_timer == null || !(_timer?.isActive ?? false)) {
      _timer = Timer(duration, () {
        callback.call();
        _timer?.cancel();
        _timer = null;
      },);
    }
  }
}

final debounce = Debounce.instance;