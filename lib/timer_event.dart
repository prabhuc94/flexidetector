import 'dart:async';
import 'dart:developer';
import 'package:flexidetector/debouncer.dart';
import 'package:flexidetector/keboard_mouse_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:flexidetector/enumeration.dart';

class TimerEvent {
  TimerEvent._() {
    _startMonitoring();
  }

  static final TimerEvent instance = TimerEvent._();

  Duration _idleDuration = const Duration(minutes: 1);
  Duration _breakDuration = const Duration(minutes: 2);

  Timer? _timer;
  late DateTime _lastActivityTime;
  late DateTime _timerStartTime;
  late DateTime _activityStartTime;
  late DateTime _lastUpdatedActivityTime;

  final zeroDuration = const Duration(seconds: 0);

  final _tag = "TIMER-EVENT";

  Function(DateTime)? _updateEvent;

  Function(List<TimerEventModel>)? _statusEvent;

  bool _privateToggled = false;

  Duration _periodicDuration = const Duration(minutes: 1);

  bool _disposed = false;

  void _startMonitoring() {
    keyboardMouseDetector.listenKeyMouseEvent.listen((event) {
      if ((event is MouseMoveEvent) == false && !_privateToggled) {
        final now = DateTime.now();
        Duration  timerDifference = _timerStartTime.difference(_activityStartTime);
        _lastActivityTime = now;
        // _log("TIMER-DIFF TS:[$_timerStartTime] AS:[$_activityStartTime] DIFF:[$timerDifference]");
        if( timerDifference >= zeroDuration ) {
          _activityStartTime = now;
          // _log("_startTimer()-------1------- >>  $timerDifference     $zeroDuration [$_activityStartTime]");
        }
        // _log("_startTimer()-------2------- >>  $timerDifference     $zeroDuration  $_lastActivityTime   $_timerStartTime    $_activityStartTime");
      }
    });
    final now = DateTime.now();
    _lastActivityTime = now;
    _timerStartTime = now;
    _activityStartTime = now;
    _lastUpdatedActivityTime= now;
    // _log("_startTimer()-------3------- >>  $_lastActivityTime     $_timerStartTime  $_activityStartTime $_lastUpdatedActivityTime");
    _startTimer();
  }

  void _startTimer( ){
    _timer?.cancel();
    _disposed = false;
    _timer = Timer.periodic(_periodicDuration, (timer)
    {
      if (_privateToggled == false) {
        Duration difference = _activityStartTime.difference(_lastUpdatedActivityTime);
        // Duration  timerDifference = (_timerStartTime.isAfter(_lastActivityTime)) ? _timerStartTime.difference(_lastActivityTime) : _lastActivityTime.difference(_timerStartTime);
        Duration  timerDifference = _lastActivityTime.difference(_timerStartTime);
        // _log("START-TIME[(${(_timerStartTime.isAfter(_lastActivityTime))})] [$_timerStartTime] [$_lastActivityTime] [$timerDifference]");
        // _log("_startTimer-------10------- Difference between last active  >> $timerDifference  $difference     $_idleDuration     $_breakDuration [$_activityStartTime] [$_lastUpdatedActivityTime]");
        // _log("TIMER-DIFFERENCE [${(timerDifference > zeroDuration)}] [${(timerDifference < zeroDuration)}]");
        if (timerDifference > zeroDuration) {
          if (difference < _idleDuration) {
            // _log("_startTimer-------4------- Active until  >>  $_lastActivityTime");

            //Update last record end time with _lastActivityTime
            if (periodicDuration.inMinutes != 1) {
              debounce.run(() => _updateEvent?.call(_lastActivityTime), duration: const Duration(minutes: 1));
            } else {
              _updateEvent?.call(_lastActivityTime);
            }
          } else if (difference >= _idleDuration && difference < _breakDuration) {
            // _log("_startTimer-------5------- Idle between >>  $_lastUpdatedActivityTime $_activityStartTime");

            // _log("_startTimer-------6------- Active at  >> $_activityStartTime    $_lastActivityTime");

            //Insert new idle record start from _lastUpdatedActivityTime to _activityStartTime

            //Insert new active record start from _activityStartTime to _lastActivityTime

            _statusEvent?.call([
              TimerEventModel(status: ActivityStatus.IDLE, startTime: _lastUpdatedActivityTime, endTime: _activityStartTime),
              TimerEventModel(status: ActivityStatus.ACTIVE, startTime: _activityStartTime, endTime: _lastActivityTime),
            ]);

          } else if (difference >= _breakDuration) {
            // _log("_startTimer-------7------- Break between >>  $_lastUpdatedActivityTime $_activityStartTime");

            // _log("_startTimer-------8------- Active at  >> $_activityStartTime    $_lastActivityTime");

            //Insert new break record start from _lastUpdatedActivityTime to _activityStartTime

            //Insert new active record start from _activityStartTime to _lastActivityTime

            _statusEvent?.call([
              TimerEventModel(status: ActivityStatus.BREAK, startTime: _lastUpdatedActivityTime, endTime: _activityStartTime),
              TimerEventModel(status: ActivityStatus.ACTIVE, startTime: _activityStartTime, endTime: _lastActivityTime),
            ]);

          }
          _lastUpdatedActivityTime = _lastActivityTime;
          _activityStartTime = DateTime.now();
          // _log("_startTimer()-------9------- >>  $difference     $_activityStartTime");
        }
        final now = DateTime.now();
        _timerStartTime = now;
      } else {
        // UPDATING EVENT EVERY ONE MINUTE FOR PRIVATE LOG
        if (periodicDuration.inMinutes != 1) {
          debounce.run(() => _updateEvent?.call(DateTime.now()), duration: const Duration(minutes: 1));
        } else {
          _updateEvent?.call(DateTime.now());
        }
      }
    });
  }


  set periodicDuration(Duration value) {
    _periodicDuration = value;
    _log("TIMER-PERIODIC-DURATION-SET [$_periodicDuration]");
  }

  void pause() {
    _timer?.cancel();
    _log("TIMER-STOPPED");
  }

  bool get isTimerPaused => (_timer?.isActive ?? false);

  void play() {
    final now = DateTime.now();
    _lastActivityTime = now;
    _timerStartTime = now;
    _activityStartTime = now;
    _lastUpdatedActivityTime= now;
    _startTimer();
    _log("TIMER-RESTARTED");
  }

  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _log("TIMER-DISPOSED");
  }

  set privateToggle(bool value) {
    _privateToggled = value;
    _log("PRIVATE-FLAG-MODIFIED: ${_privateToggled ? "ENABLED" : "DISABLED"}");
  }

  set breakDuration(Duration value) {
    _breakDuration = value;
    _log("NEW-BREAK-TIME:\t${_breakDuration.inMinutes} IS SET");
  }

  set idleDuration(Duration value) {
    _idleDuration = value;
    _log("NEW-IDLE-TIME:\t${_idleDuration.inMinutes} IS SET");
  }

  bool get isTicking => (_timer?.isActive ?? false);

  bool get privateToggled => _privateToggled;

  Duration get periodicDuration => _periodicDuration;

  bool get isDisposed => _disposed;

  void _log(String message) {
    if (kDebugMode) {
      log(message, name: _tag, time: DateTime.now());
    }
  }

  set updateEvent(Function(DateTime) value) => _updateEvent = value;

  set statusEvent(Function(List<TimerEventModel>) value) => _statusEvent = value;
}

final timerEvent = TimerEvent.instance;

class TimerEventModel {
  ActivityStatus status;
  DateTime startTime;
  DateTime endTime;

  TimerEventModel({required this.status, required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() => {
    "status" : status.name,
    "startTime" : startTime.toLocal().toIso8601String(),
    "endTime" : endTime.toLocal().toIso8601String()
  };
}