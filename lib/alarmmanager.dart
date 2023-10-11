import 'dart:async';

import 'package:flutter/foundation.dart';

class AlarmManager {
  AlarmManager._();

  static final AlarmManager instance = AlarmManager._();

  Timer? _alarmTimer;

  // ONCE REACHES TIMER WILL STOP
  void setAlarm({required DateTime input, VoidCallback? callback}) {
    final now = DateTime.now();
    if (kDebugMode) {
      print("INPUT:\t${input}");
    }
    final delay = input.difference(now);
    if (kDebugMode) {
      print("DELAY:\t${delay} NOW[$now]");
    }
    _alarmTimer?.cancel();
    _alarmTimer = Timer(delay, () => callback?.call());
  }

  // ONCE TIME REACHES IT'LL REPEAT TO NEXT DAY
  void repeatAlarm({required DateTime input, VoidCallback? callback}) {
    final now = DateTime.now();
    if (kDebugMode) {
      print("INPUT:\t${input}");
    }
    final delay = input.difference(now);
    if (kDebugMode) {
      print("DELAY:\t${delay} NOW[$now]");
    }
    _alarmTimer?.cancel();
    _alarmTimer = Timer(delay, () {
      repeatAlarm(input: input.add(const Duration(days: 1)), callback: callback);
      callback?.call();
    });
  }
}